const fs = require("fs");

(async () => {
    if (!fs.existsSync("overpy_standalone.js")) {
        console.log("Downloading overpy_standalone.js");
        const content = await fetch(
            "https://raw.githubusercontent.com/ItsDeltin/overpy/refs/heads/master/out/overpy_standalone.js"
        );
        fs.writeFileSync("overpy_standalone.js", await content.text());
    }
    decompile();
})();

async function decompile() {
    console.log("Decompiling scripts");
    const overpy_standalone = require("./overpy_standalone.js");
    await overpy_standalone.readyPromise;

    function decompileFile(readFile, writeFile) {
        const text = fs.readFileSync(readFile, { encoding: "utf8" });
        let decompilation;
        try {
            decompilation = overpy_standalone.decompileAllRules(text, "en-US", {
                ignoreVariableIndex: true,
                ignoreSubroutineIndex: true,
            });
        } catch (ex) {
            console.log(`Error while decompiling ${readFile}: ${ex}`);
            return;
        }
        fs.writeFileSync(writeFile, decompilation);
        console.log(`${readFile} -> ${writeFile}`);
    }

    decompileFile("core.ow", "core.opy");
}
