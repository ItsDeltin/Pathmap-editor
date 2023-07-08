import Vector from "../model/Vector";
import { exportActions } from "../workshop/exportWorkshop";
import { Assignment } from "../workshop/workshop";
import {
    WorkshopValue,
    array,
    boolean,
    customString,
    hero,
    number,
    vector,
} from "../workshop/workshopValue";

export function saveToWorkshop(save: PathmapSave): string {
    const nextNodeId = nextIdFromIdArray(save.nodes.map((n) => n.id));
    const nextSegmentId = nextIdFromIdArray(save.segments.map((n) => n.id));
    const nextAttributeId = nextIdFromIdArray(save.attributes.map((n) => n.id));

    const actions = [
        // todo: version
        set("__loadPersist", boolean(true)),
        set("version", number(-1)),
        set("NodeUniqueID", number(nextNodeId)),
        set("SegmentUniqueID", number(nextSegmentId)),
        set("AttributeUniqueID", number(nextAttributeId)),
        set(
            "Nodes_Node_UniqueID",
            mapNumber(save.nodes, (s) => s.id)
        ),
        set(
            "Nodes_Node_Position",
            array(save.nodes.map((n) => vector(n.position)))
        ),
        set(
            "Segments_ID",
            mapNumber(save.segments, (s) => s.id)
        ),
        set(
            "Segments_Node1",
            mapNumber(save.segments, (s) => s.node1)
        ),
        set(
            "Segments_Node2",
            mapNumber(save.segments, (s) => s.node2)
        ),
        set(
            "Attributes_Value",
            mapNumber(save.attributes, (s) => s.value)
        ),
        set(
            "Attributes_ID",
            mapNumber(save.attributes, (s) => s.id)
        ),
        set(
            "Attributes_Node1",
            mapNumber(save.attributes, (s) => s.node1)
        ),
        set(
            "Attributes_Node2",
            mapNumber(save.attributes, (s) => s.node2)
        ),
        set(
            "Rules_Actions_Data",
            array(
                save.rules.map((rule) =>
                    array(
                        rule.actions.map((action) =>
                            array([number(action.actionId), action.extraData])
                        )
                    )
                )
            )
        ),
        set(
            "Rules_ExecutesOnAttribute",
            mapNumber(save.rules, (rule) => rule.attribute)
        ),
        set(
            "Rules_EnabledHeroes",
            array(
                save.rules.map((rule) =>
                    array([
                        boolean(rule.heroToggle),
                        ...rule.toggledHeroes.map((h) => hero(h)),
                    ])
                )
            )
        ),
    ];
    if (save.map) {
        actions.push(set("map", customString(save.map)));
    }
    if (save.playerLocation) {
        actions.push(set("savedPlayerLocation", vector(save.playerLocation)));
    }
    if (save.playerDirection) {
        actions.push(set("savedPlayerDirection", vector(save.playerDirection)));
    }
    if (save.isNoClipping) {
        actions.push(set("IsNoClipping", boolean(save.isNoClipping)));
    }
    return exportActions(actions);
}

function set(variable: string, value: WorkshopValue): Assignment {
    return { identifier: variable, isGlobal: true, value };
}

function mapNumber<T>(arr: T[], callbackFn: (value: T) => number) {
    return array(arr.map((value) => number(callbackFn(value))));
}

function nextIdFromIdArray(ids: number[]): number {
    return ids.length === 0
        ? 1
        : ids.reduce((id1, id2) => Math.max(id1, id2)) + 1;
}

export interface PathmapSave {
    map?: string;
    nodes: PfNode[];
    segments: PfSegment[];
    attributes: PfAttribute[];
    playerLocation?: Vector;
    playerDirection?: Vector;
    isNoClipping?: boolean;
    rules: PfRule[];
}

export interface PfNode {
    position: Vector;
    id: number;
}

export interface PfSegment {
    node1: number;
    node2: number;
    id: number;
}

export interface PfAttribute extends PfSegment {
    value: number;
}

export interface PfRule {
    attribute: number;
    toggledHeroes: string[];
    heroToggle: boolean;
    actions: PfAction[];
}

export interface PfAction {
    actionId: number;
    extraData: WorkshopValue;
}
