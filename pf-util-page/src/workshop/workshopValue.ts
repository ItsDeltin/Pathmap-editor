import Vector from "../model/Vector";

export function array(values: WorkshopValue[]): ArrayValue {
    return {
        type: "array",
        elements: values,
    };
}

export function number(value: number): NumberValue {
    return {
        type: "number",
        value,
    };
}

export function vector(value: Vector): VectorValue {
    return {
        type: "vector",
        x: value.x,
        y: value.y,
        z: value.z,
    };
}

export function boolean(value: boolean): BooleanValue {
    return {
        type: "boolean",
        value,
    };
}

export function customString(text: string): StringValue {
    return {
        type: "string",
        text,
    };
}

export function hero(hero: string): HeroValue {
    return {
        type: "hero",
        hero,
    };
}

export function toLiteralNumber(
    value: WorkshopValue | undefined
): number | undefined {
    return value?.type === "number" ? value.value : undefined;
}

export function toLiteralVector(
    value: WorkshopValue | undefined
): Vector | undefined {
    return value?.type === "vector" ? value : undefined;
}

export function toLiteralBoolean(
    value: WorkshopValue | undefined
): boolean | undefined {
    return value?.type === "boolean" ? value.value : undefined;
}

export function toLiteralString(
    value: WorkshopValue | undefined
): string | undefined {
    switch (value?.type) {
        case "string":
            return value.text;
        case "map":
            return value.map;
        case "color":
            return value.color;
        case "hero":
            return value.hero;
        default:
            return undefined;
    }
}

export type ArrayValue = {
    type: "array";
    elements: WorkshopValue[];
};
export type NumberValue = {
    type: "number";
    value: number;
};
export type StringValue = {
    type: "string";
    text: string;
};
export type VectorValue = {
    type: "vector";
    x: number;
    y: number;
    z: number;
};
export type BooleanValue = {
    type: "boolean";
    value: boolean;
};
export type ColorValue = {
    type: "color";
    color: string | undefined;
};
export type HeroValue = {
    type: "hero";
    hero: string | undefined;
};
export type MapValue = {
    type: "map";
    map: string | undefined;
};
export type NullValue = {
    type: "null";
};

export type WorkshopValue =
    | ArrayValue
    | NumberValue
    | StringValue
    | VectorValue
    | BooleanValue
    | ColorValue
    | HeroValue
    | MapValue
    | NullValue;
