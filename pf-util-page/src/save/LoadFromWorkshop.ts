import ErrorReport from "../model/ErrorReport";
import { Assignment } from "../workshop/workshop";
import {
    ArrayValue,
    WorkshopValue,
    toLiteralBoolean,
    toLiteralNumber,
    toLiteralString,
    toLiteralVector,
} from "../workshop/workshopValue";
import {
    PathmapSave,
    PfAction,
    PfAttribute,
    PfNode,
    PfRule,
    PfSegment,
} from "./PathmapSave";

function loadFromWorkshop(
    assignments: Assignment[],
    errorReport: ErrorReport
): PathmapSave | undefined {
    const loader = new PathmapLoader(assignments, errorReport);
    // Get optional values.
    const version = loader.find("version", "number", false, (v) =>
        toLiteralNumber(v)
    );
    const map = loader.find("map", "map", false, (v) => toLiteralString(v));
    const savedPlayerLocation = loader.findVector("savedPlayerLocation");
    const savedPlayerDirection = loader.findVector("savedPlayerDirection");
    const isNoClipping = loader.findBoolean("IsNoclipping") ?? false;
    // Nodes
    const nodeUniqueIds = loader.findNumberArray("Nodes_Node_UniqueID");
    const nodePositions = loader.findVectorArray("Nodes_Node_Position");
    // Segments
    const segmentsId = loader.findNumberArray("Segments_ID");
    const segmentsNode1 = loader.findNumberArray("Segments_Node1");
    const segmentsNode2 = loader.findNumberArray("Segments_Node2");
    // Attributes
    const attributesValue = loader.findNumberArray("Attributes_Value");
    const attributesId = loader.findNumberArray("Attributes_ID");
    const attributesNode1 = loader.findNumberArray("Attributes_Node1");
    const attributesNode2 = loader.findNumberArray("Attributes_Node2");
    // Rules
    const rulesExecuteOnAttribute = loader.findNumberArray(
        "Rules_ExecutesOnAttribute"
    );
    const rulesActions = loader.findArray(
        "Rules_Actions_Data",
        undefined,
        false,
        (ruleActionArray) => {
            // Ensure action list is array.
            if (ruleActionArray.type !== "array") {
                loader.log(
                    "Incorrect 'Rules_Actions_Data' format: Rule action list is not an array",
                    true
                );
                return;
            }
            const actions = [] as PfAction[];
            for (const actionList of ruleActionArray.elements) {
                // Make sure action data is an array.
                if (actionList.type !== "array") {
                    loader.log(
                        "Incorrect 'Rules_Actions_Data' format: Malformed action in rule's action list",
                        true
                    );
                    return;
                }
                // Make sure there are two elements in the action list data.
                if (actionList.elements.length !== 2) {
                    loader.log(
                        "Incorrect 'Rules_Actions_Data' format: action is incorrect size",
                        true
                    );
                    return;
                }
                // Make sure the ID parameter is valid.
                if (actionList.elements[0].type !== "number") {
                    loader.log(
                        "Incorrect 'Rules_Actions_Data' format: action ID is not a number",
                        true
                    );
                    return;
                }
                // Action is ok
                actions.push({
                    actionId: actionList.elements[0].value,
                    extraData: actionList.elements[1],
                });
            }
            return actions;
        }
    );
    const rulesEnabledHeroes = loader.findArray(
        "Rules_EnabledHeroes",
        undefined,
        false,
        (heroList) => {
            // Make sure the rule hero list is an array.
            if (heroList.type !== "array") {
                loader.log(
                    "Incorrect 'Rules_EnabledHeroes' format: Hero list is not an array",
                    true
                );
                return;
            }

            let toggle = false;
            const heroes: string[] = [];

            // The hero list has a toggle.
            if (
                heroList.elements.length === 0 ||
                heroList.elements[0].type !== "boolean"
            ) {
                loader.log(
                    "Incorrect 'Rules_EnabledHeroes' format: First item in hero list must be a toggle",
                    true
                );
                return;
            }

            // Add hero values
            for (const hero of heroList.elements.slice(1)) {
                // Make sure this is a hero value.
                if (hero.type !== "hero") {
                    loader.log(
                        "Incorrect 'Rules_EnabledHeroes' format: Value in hero list is not a hero",
                        true
                    );
                    return;
                }
                if (hero.hero) {
                    heroes.push(hero.hero);
                }
            }

            return { toggle, heroes };
        }
    );

    if (
        !loader.checkHarmonious([
            ["Nodes_Node_UniqueID", "Nodes_Node_Position"],
            ["Segments_ID", "Segments_Node1", "Segments_Node2"],
            [
                "Attributes_Value",
                "Attributes_ID",
                "Attributes_Node1",
                "Attributes_Node2",
            ],
        ])
    ) {
        return;
    }

    let nodes: PfNode[] = [];
    if (nodeUniqueIds && nodePositions) {
        nodes = nodeUniqueIds.map((id, i) => ({
            id,
            position: nodePositions[i],
        }));
    }

    let segments: PfSegment[] = [];
    if (segmentsId && segmentsNode1 && segmentsNode2) {
        segments = segmentsId.map((id, i) => ({
            id,
            node1: segmentsNode1[i],
            node2: segmentsNode2[i],
        }));
    }

    let attributes: PfAttribute[] = [];
    if (attributesId && attributesNode1 && attributesNode2 && attributesValue) {
        attributes = attributesId.map((id, i) => ({
            id,
            node1: attributesNode1[i],
            node2: attributesNode2[i],
            value: attributesValue[i],
        }));
    }

    let rules: PfRule[] = [];
    if (rulesExecuteOnAttribute && rulesActions && rulesEnabledHeroes) {
        rules = rulesExecuteOnAttribute.map((attribute, i) => ({
            attribute,
            actions: rulesActions[i],
            heroToggle: rulesEnabledHeroes[i].toggle,
            toggledHeroes: rulesEnabledHeroes[i].heroes,
        }));
    }

    return {
        map,
        isNoClipping,
        playerLocation: savedPlayerLocation,
        playerDirection: savedPlayerDirection,
        nodes,
        segments,
        attributes,
        rules,
    };
}

class PathmapLoader {
    private hasError: boolean = false;

    public constructor(
        private assignments: Assignment[],
        private errorReporter: ErrorReport
    ) {}

    private get(name: string) {
        return this.assignments.find((a) => a.identifier === name)?.value;
    }

    public log(text: string, isError: boolean) {
        if (isError) {
            this.hasError = true;
        }
        const errorType = isError ? "error" : "warning";
        this.errorReporter.log(text, errorType);
    }

    public find<T>(
        name: string,
        expectedType: string,
        required: boolean,
        convert: (value: WorkshopValue) => T
    ): T | undefined {
        const value = this.get(name);
        if (!value) {
            this.log(`'${name}' value missing`, required);
            return undefined;
        } else if (value.type !== expectedType) {
            this.log(`'${name}' is not a ${expectedType}`, required);
            return undefined;
        }
        return convert(value);
    }

    public findArray<T>(
        name: string,
        expectedInnerType: string | undefined,
        required: boolean,
        convertInner: (value: WorkshopValue) => T | undefined
    ): T[] | undefined {
        return this.find(name, "array", required, (value) => {
            const array: ArrayValue = value as ArrayValue;
            const result = [] as T[];

            for (const element of array.elements) {
                if (expectedInnerType && element.type !== expectedInnerType) {
                    this.log(
                        `'${name}' must be an array of all ${expectedInnerType}s`,
                        true
                    );
                    break;
                }

                const next = convertInner(element);
                if (!next) {
                    break;
                }
                result.push(next);
            }

            return result;
        });
    }

    public findVectorArray(name: string) {
        return this.findArray(name, "vector", false, (v) => toLiteralVector(v));
    }

    public findNumberArray(name: string) {
        return this.findArray(name, "number", false, (v) => toLiteralNumber(v));
    }

    public findVector(name: string) {
        return this.find(name, "vector", false, (v) => toLiteralVector(v));
    }

    public findNumber(name: string) {
        return this.find(name, "number", false, (v) => toLiteralNumber(v));
    }

    public findBoolean(name: string) {
        return this.find(name, "boolean", false, (v) => toLiteralBoolean(v));
    }

    public checkHarmonious(groups: string[][]) {
        for (const group of groups) {
            const item = group.findIndex((v) => this.get(v));
            // Is there at least one group item in the variable set?
            if (item !== -1) {
                // Ensure every item in the group exists.
                if (!group.every((v) => this.get(v))) {
                    this.log(
                        `Variable '${
                            group[item]
                        }' is dependent on variables ${group
                            .slice(item, 1)
                            .map((dependent) => `'${dependent}'`)
                            .join(", ")} but one or more is missing`,
                        true
                    );
                    return false;
                }

                // Ensure every item is the same length (assume all are arrays at this point)
                const itemCount = (this.get(group[item]) as ArrayValue).elements
                    .length;
                if (
                    !group.every(
                        (g) =>
                            (this.get(g) as ArrayValue).elements.length ===
                            itemCount
                    )
                ) {
                    this.log(
                        `Variables ${group
                            .map((dependent) => `'${dependent}'`)
                            .join(", ")} must be the same length`,
                        true
                    );
                    return false;
                }
            }
        }
        return true;
    }
}

export default loadFromWorkshop;
