import {
    Assignment,
    DeclaredWorkshopVariable,
    VariableCollection,
    Workshop,
    WorkshopRule,
} from "./workshop";
import * as workshop from "./workshopValue";

export function parseActionSet(text: string) {
    const parser = new ActionSetParser(text);
    return parser.parse();
}

export function tryParseAssignment(
    text: string
): Assignment | undefined | Error {
    const parser = new ActionSetParser(text);
    try {
        const result = parser.parseAssignment();
        if (result === null) {
            return undefined;
        }
        return result;
    } catch (e: any) {
        if (e instanceof Error) {
            return e;
        }
        throw e;
    }
}

class ActionSetParser {
    character: number = 0;
    text: string;

    public constructor(text: string) {
        this.text = text;
    }

    skipWhitespace() {
        while (/\s/.test(this.text[this.character])) this.character++;
    }

    match(regex: RegExp) {
        const result = regex.exec(this.text.substring(this.character));
        if (result) {
            this.character += result[0].length;
            this.skipWhitespace();
            return result[0];
        }
        return null;
    }
    matchKw(keyword: string, caseSensitive: boolean = true) {
        for (let i = 0; i < keyword.length; i++) {
            let character = this.text.at(i + this.character);

            if (
                character === undefined ||
                (caseSensitive && character !== keyword[i]) ||
                (!caseSensitive &&
                    character.toLowerCase() !== keyword[i].toLowerCase())
            )
                return false;
        }
        this.character += keyword.length;
        this.skipWhitespace();
        return true;
    }
    matchSymbol(symbol: string) {
        return this.matchKw(symbol);
    }
    matchNumber() {
        const match = this.match(/^-?[0-9]+(\.[0-9]+)?/);
        return match ? Number.parseFloat(match) : undefined;
    }
    matchIdentifier() {
        return this.match(/^[a-zA-Z0-9_]+/);
    }
    matchWorkshopValue() {
        return this.match(/^[^(),;]+/);
    }
    matchString() {
        if (this.text[this.character] !== '"') {
            return undefined;
        }

        this.character += 1;
        let escape = false;
        let text = "";

        while (this.character < this.text.length) {
            const char = this.text[this.character];
            if (escape) {
                escape = false;
            } else if (char === "\\") {
                escape = true;
            } else if (char === '"') {
                this.character += 1;
                this.skipWhitespace();
                return text;
            }
            text += char;
            this.character += 1;
        }
        // Unclosed string.
        return text;
    }
    expectSymbol(symbol: string) {
        if (!this.matchSymbol(symbol)) {
            this.expected(symbol);
        }
    }
    expectNumber() {
        const number = this.matchNumber();
        if (number === undefined) {
            this.expected("number");
        }
        return number;
    }
    expectIdentifier() {
        const identifier = this.matchIdentifier();
        if (!identifier) {
            this.expected("identifier");
        }
        return identifier;
    }
    expectString() {
        const string = this.matchString();
        if (!string) {
            this.expected("string");
        }
        return string;
    }
    expectKw(keyword: string) {
        const kw = this.matchKw(keyword);
        if (!kw) {
            this.expected(`"${keyword}"`);
        }
        return kw;
    }
    expected(value: string): never {
        const got = this.getSymbol();
        this.throwErrorHere(`Expected '${value}' got '${got}'`);
    }
    unexpected(): never {
        const got = this.getSymbol();
        this.throwErrorHere(`Unexpected symbol '${got}'`);
    }
    getSymbol() {
        const nextSymbol = /\S+/.exec(this.text.substring(this.character));
        return nextSymbol?.[0] ?? "EOF";
    }
    throwErrorHere(message: string): never {
        const { line, column } = this.lineAndColumnFromIndex();
        throw new Error(`${message} at line ${line}, column ${column}`);
    }

    public parse(): Workshop | Error {
        try {
            let variables: VariableCollection[] | null = null;
            let actions: Assignment[] | null = null;
            let rules: WorkshopRule[] | null = null;
            while (this.character < this.text.length) {
                this.skipWhitespace();

                // Try to parse variables.
                const iterVariables = this.parseVariables();
                if (iterVariables) {
                    variables = iterVariables;
                }

                // Try to parse actions.
                const iterActions = this.parseActions();
                if (iterActions) {
                    actions = iterActions;
                }

                // Try to parse rules.
                const rule = this.parseRule();
                if (rule) {
                    if (!rules) {
                        rules = [];
                    }
                    rules.push(rule);
                }

                if (!iterVariables && !iterActions && !rule) {
                    this.unexpected();
                }
            }
            return { variables, actions, rules };
        } catch (err) {
            if (err instanceof Error) {
                return err;
            }
            throw err;
        }
    }

    parseVariables() {
        if (!this.matchKw("variables")) return null;

        const collections = [];

        this.expectSymbol("{");
        while (true) {
            const collection = this.parseVariableCollection();
            if (collection) collections.push(collection);
            else break;
        }
        this.expectSymbol("}");

        return collections;
    }

    parseVariableCollection(): VariableCollection | null {
        const isGlobal = this.matchKw("global");
        if (!isGlobal && !this.matchKw("player")) {
            return null;
        }

        const variables: DeclaredWorkshopVariable[] = [];

        this.expectSymbol(":");
        // Match variable declaration
        while (true) {
            const number = this.matchNumber();
            if (number === undefined) break;
            this.expectSymbol(":");
            const identifier = this.expectIdentifier();
            if (identifier) {
                variables.push({ id: number, name: identifier });
            }
        }

        return { isGlobal, variables };
    }

    parseRule(): WorkshopRule | null {
        if (!this.matchKw("rule")) return null;

        this.expectSymbol("(");
        const ruleName = this.expectString();
        this.expectSymbol(")");
        this.expectSymbol("{");
        this.expectKw("event");
        this.expectSymbol("{");
        const eventType = this.parseRuleEventType();
        if (!eventType) {
            this.expected("event type");
        }
        this.expectSymbol("}");

        const conditions = this.parseConditions();
        const actions = this.parseActions();

        return {
            name: ruleName,
            eventType,
            conditions: conditions ?? [],
            actions: actions ?? [],
        };
    }

    parseRuleEventType() {
        const eventTypes = [
            "Ongoing - Global",
            "Ongoing - Each Player",
            "Subroutine",
        ];

        for (const type of eventTypes) {
            if (this.matchKw(type)) {
                this.expectSymbol(";");
                return type;
            }
        }
        return null;
    }

    parseConditions(): workshop.WorkshopValue[] | null {
        if (!this.matchKw("conditions")) return null;
        const conditions: workshop.WorkshopValue[] = [];
        this.expectSymbol("{");
        while (!this.matchSymbol("}")) {
            conditions.push(this.parseExpression());
            this.matchSymbol(";");
        }
        return conditions;
    }

    parseActions() {
        if (!this.matchKw("actions")) return null;

        const actions = [];

        this.expectSymbol("{");
        while (true) {
            const action = this.parseAssignment();
            if (action) {
                // End of statement
                this.expectSymbol(";");
                actions.push(action);
            } else break;
        }
        this.expectSymbol("}");

        return actions;
    }

    parseAssignment(): Assignment | null {
        const isGlobal = this.matchKw("Global", false);
        if (!isGlobal) return null;

        this.expectSymbol(".");

        // Match variable.
        const variable = this.matchIdentifier()!;
        // Match assignment operator.
        this.expectSymbol("=");
        // Match expression.
        const expression = this.parseExpression();

        return { isGlobal, identifier: variable, value: expression };
    }

    parseExpression(): workshop.WorkshopValue {
        let number = this.matchNumber();
        if (number !== undefined) {
            return { type: "number", value: number };
        }
        // Array
        else if (this.matchKw("Array")) {
            const arrayElements: workshop.WorkshopValue[] = [];
            this.matchSymbol("(");
            while (!this.matchSymbol(")")) {
                const nextElement = this.parseExpression();
                if (nextElement) {
                    arrayElements.push(nextElement);
                }
                this.matchSymbol(",");
            }
            return { type: "array", elements: arrayElements };
        }
        // Empty array
        else if (this.matchKw("Empty Array")) {
            return { type: "array", elements: [] };
        }
        // String
        else if (this.matchKw("Custom String")) {
            this.matchSymbol("(");
            const text = this.matchString() ?? "";
            this.matchSymbol(")");

            return { type: "string", text };
        }
        // Vector
        else if (this.matchKw("Vector")) {
            this.matchSymbol("(");
            const x = this.matchNumber() ?? 0;
            this.matchSymbol(",");
            const y = this.matchNumber() ?? 0;
            this.matchSymbol(",");
            const z = this.matchNumber() ?? 0;
            this.matchSymbol(")");

            return { type: "vector", x, y, z };
        }
        // True
        else if (this.matchKw("True")) {
            return { type: "boolean", value: true };
        }
        // False
        else if (this.matchKw("False")) {
            return { type: "boolean", value: false };
        }
        // Color
        else if (this.matchKw("Color")) {
            return { type: "color", color: this.parseLazyEnum() ?? undefined };
        }
        // Hero
        else if (this.matchKw("Hero")) {
            return { type: "hero", hero: this.parseLazyEnum() ?? undefined };
        }
        // Map
        else if (this.matchKw("Map")) {
            return { type: "map", map: this.parseLazyEnum() ?? undefined };
        }
        // Null
        else if (this.matchKw("Null")) {
            return { type: "null" };
        }
        // Unknown
        else {
            this.expected("expression");
        }
    }

    parseLazyEnum() {
        this.matchSymbol("(");
        const result = this.matchWorkshopValue();
        this.matchSymbol(")");
        return result;
    }

    lineAndColumnFromIndex() {
        let line = 1;
        let column = 1;

        for (let i = 0; i < this.text.length && i < this.character; i++) {
            const character = this.text[i];
            if (character === "\n") {
                line++;
                column = 1;
            } else {
                column++;
            }
        }
        return { line, column };
    }

    logImmediateText() {
        console.log(
            `Current text: "${this.text.substring(
                this.character,
                this.character + 10
            )}"`
        );
    }
}
