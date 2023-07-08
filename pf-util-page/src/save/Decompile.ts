import leven from "leven";
import { ConvertResult, errorToConvertResult } from "../model/AppSection";
import { tryParseAssignment } from "../workshop/parseActionSet";
import { WorkshopValue, toLiteralVector } from "../workshop/workshopValue";
import {
    PathmapSave,
    PfAttribute,
    PfNode,
    PfSegment,
    saveToWorkshop,
} from "./PathmapSave";

function decompile(text: string): ConvertResult {
    const commentRegex = /("(?:[^"\\]|\\.)*"?)|(\/\*.*?\*\/)\s*|(\/\/.*?$)/gms;
    text = text
        .replace(commentRegex, (replace) => {
            // Do not filter strings.
            if (replace.startsWith('"')) return replace;
            // Clear comments.
            return "";
        })
        .trim();
    text = text.replace(/\/\*\s*$/s, "");

    try {
        const { WorkshopDeserialize } = require("@workshopcodes/deserializer");
        const workshopData = WorkshopDeserialize(text);

        if (!("rules" in workshopData)) return {};

        // Get assigned nodes and neighbors.
        const { nodes, neighbors } = itemsFromRules(workshopData.rules);

        // Pair nodes and neighbors.
        const pairs = pairRules(nodes, neighbors);

        return {
            result: pairs.flatMap((p) => {
                const save = saveFromPair(p);
                return save
                    ? {
                          title: p.name,
                          text: saveToWorkshop(save),
                      }
                    : [];
            }),
        };
    } catch (e: any) {
        const error = `${e}`.replace(/Error:.*?PARSING FAILED -*/gms, "");
        return errorToConvertResult(error);
    }
}

function itemsFromRules(rules: any[]) {
    const nodes: MapItem[] = [];
    const neighbors: MapItem[] = [];

    for (const rule of rules) {
        const name: string = rule.title;

        for (const action of rule.code.actions as string[]) {
            const assignment = tryParseAssignment(action);
            // Ignore if not assignment or is an error
            if (assignment === undefined || assignment instanceof Error) {
                continue;
            }

            if (assignment.identifier === "pfLoadedMap_nodes") {
                nodes.push({
                    ruleName: name,
                    value: assignment.value,
                });
            } else if (assignment.identifier === "pfLoadedMap_neighbors") {
                neighbors.push({
                    ruleName: name,
                    value: assignment.value,
                });
            }
        }
    }

    return { nodes, neighbors };
}

function pairRules(nodes: MapItem[], neighbors: MapItem[]): MapPair[] {
    return nodes.flatMap((nodeItem) => {
        const chosenNeighborSet = neighbors
            .sort((neighborItem) =>
                leven(nodeItem.ruleName, neighborItem.ruleName)
            )
            .at(-1);

        return chosenNeighborSet
            ? {
                  name: nodeItem.ruleName,
                  nodes: nodeItem.value,
                  neighbors: chosenNeighborSet.value,
              }
            : [];
    });
}

function saveFromPair(pair: MapPair): PathmapSave | undefined {
    if (pair.nodes.type === "array" && pair.neighbors.type === "array") {
        const nodes: PfNode[] = pair.nodes.elements.flatMap((e, i) => ({
            position: toLiteralVector(e) ?? { x: 0, y: 0, z: 0 },
            id: i + 1,
        }));

        const attributes: PfAttribute[] = [];
        let currentAttributeId = 1;

        const segments: PfSegment[] = [];
        let currentSegmentId = 1;

        for (let i = 0; i < pair.neighbors.elements.length; i++) {
            const nodeNeighbors = pair.neighbors.elements[i];
            if (nodeNeighbors.type === "array") {
                // Get the nodes that the current node is connected to.
                for (const segment of nodeNeighbors.elements) {
                    // Make sure segment info matches export pattern.
                    if (
                        segment.type === "array" &&
                        segment.elements.length === 2 &&
                        segment.elements[0].type === "number" &&
                        segment.elements[1].type === "array"
                    ) {
                        const connectingNode = segment.elements[0].value + 1;
                        // Attribute values between node `i` and `connectingNode`.
                        const segmentAttributes =
                            segment.elements[1].elements.flatMap((e, i) =>
                                e.type === "number" ? e.value : []
                            );

                        // Add segment.
                        if (
                            !segments.some(
                                (s) =>
                                    (s.node1 === i + 1 &&
                                        s.node2 === connectingNode) ||
                                    (s.node2 === i + 1 &&
                                        s.node1 === connectingNode)
                            )
                        ) {
                            segments.push({
                                node1: i + 1,
                                node2: connectingNode,
                                id: currentSegmentId,
                            });
                            currentSegmentId++;
                        }

                        // Add attributes.
                        for (const segmentAttribute of segmentAttributes) {
                            attributes.push({
                                id: currentAttributeId,
                                node1: connectingNode,
                                node2: i + 1,
                                value: segmentAttribute,
                            });
                            currentAttributeId++;
                        }
                    }
                }
            }
        }

        return {
            nodes,
            segments,
            attributes,
            rules: [],
        };
    }
}

interface MapItem {
    ruleName: string;
    value: WorkshopValue;
}

interface MapPair {
    name: string;
    nodes: WorkshopValue;
    neighbors: WorkshopValue;
}

export default decompile;
