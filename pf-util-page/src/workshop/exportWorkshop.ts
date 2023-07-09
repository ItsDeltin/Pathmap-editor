import { Assignment } from "./workshop";
import { WorkshopValue } from "./workshopValue";

/**
 * Converts the workshop actions into a string that can be pasted inside workshop rules.
 */
export function exportActions(assignments: Assignment[]) {
    let result = "actions {\n";

    for (const assignment of assignments) {
        result += `    ${assignment.isGlobal ? "Global" : ""}.${
            assignment.identifier
        } = ${exportValue(assignment.value)};\n`;
    }

    result += "}";
    return result;
}

function exportValue(value: WorkshopValue): string {
    switch (value.type) {
        case "array":
            if (value.elements.length === 0) return "Empty Array";
            else
                return `Array(${value.elements
                    .map((e) => exportValue(e))
                    .join(", ")})`;
        case "boolean":
            return value.value ? "True" : "False";
        case "color":
            return `Color(${value.color})`;
        case "hero":
            return `Hero(${value.hero})`;
        case "map":
            return `Map(${value.map})`;
        case "null":
            return "Null";
        case "number":
            return value.value.toString();
        case "string":
            return `Custom String("${value.text}")`;
        case "vector":
            return `Vector(${value.x}, ${value.y}, ${value.z})`;
    }
}
