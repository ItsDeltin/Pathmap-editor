import { PathmapSave } from "./PathmapSave";

function loadFromOldJson(text: string): PathmapSave | Error {
    try {
        const json = JSON.parse(text);
        if (!isJsonValid(json)) {
            return Error("Json is not in the correct format");
        }
        const pathmap = json as OldJsonPathmap;

        return {
            nodes: pathmap.Nodes.map((n, i) => ({
                id: i + 1,
                position: { x: n.X, y: n.Y, z: n.Z },
            })),
            segments: pathmap.Segments.map((s, i) => ({
                id: i + 1,
                node1: s.Node1 + 1,
                node2: s.Node2 + 1,
            })),
            attributes: pathmap.Attributes.map((a, i) => ({
                id: i + 1,
                node1: a.Node1 + 1,
                node2: a.Node2 + 1,
                value: a.Attribute,
            })),
            rules: [],
        };
    } catch (ex: any) {
        if (ex instanceof Error) return ex;
        return Error(ex.toString());
    }
}

function isJsonValid(value: unknown): value is OldJsonPathmap {
    return (
        typeof value === "object" &&
        value != null &&
        "Nodes" in value &&
        "Segments" in value &&
        "Attributes" in value &&
        value.Nodes instanceof Array &&
        value.Segments instanceof Array &&
        value.Attributes instanceof Array &&
        value.Nodes.every((n) => "X" in n && "Y" in n && "Z" in n) &&
        value.Segments.every((n) => "Node1" in n && "Node2" in n) &&
        value.Attributes.every(
            (n) => "Node1" in n && "Node2" in n && "Attribute" in n
        )
    );
}

interface OldJsonPathmap {
    Nodes: { X: number; Y: number; Z: number }[];
    Segments: { Node1: number; Node2: number }[];
    Attributes: { Node1: number; Node2: number; Attribute: number }[];
}

export default loadFromOldJson;
