import React from 'react';
import './App.css';
import { AppSection, Diagnostic, errorToConvertResult, textToConvertResult, useTextConverterSection } from './model/AppSection';
import HeaderAndContent from './HeaderAndContent';
import { parseActionSet } from './workshop/parseActionSet';
import loadFromWorkshop from './save/LoadFromWorkshop';
import loadFromOldJson from './save/LoadFromOldJson';
import { saveToWorkshop } from './save/PathmapSave';
import decompile from './save/Decompile';

export const currentVersion: number = 3;

function App() {
    const PF_WORKSHOP_SAVE_NAME = 'Workshop code (Pathmap save)';
    const SECTIONS: AppSection[] = [
        useTextConverterSection(
            'Clean up and update save',
            <div>Fixes outdated saves and removes unused variables.<br /><br />
                Saves copied from Overwatch may have a high element count or be outdated for current pathmap versions.</div>,
            'Update',
            PF_WORKSHOP_SAVE_NAME,
            PF_WORKSHOP_SAVE_NAME,
            code => {
                // convert code to workshop.
                const workshop = parseActionSet(code);
                // Parsing error
                if (workshop instanceof Error) {
                    return errorToConvertResult(workshop);
                }
                // Incorrect type
                if (!workshop.actions) {
                    return errorToConvertResult(Error('Save should be a list of actions'));
                }

                const diagnostics: Diagnostic[] = [];
                // Load save
                const pathmap = loadFromWorkshop(workshop.actions, {
                    log(text, type) {
                        diagnostics.push({ message: text, type });
                    }
                });

                return {
                    diagnostics,
                    result: pathmap ? [{ text: saveToWorkshop(pathmap) }] : []
                }
            }
        ),
        useTextConverterSection(
            'Pathmap save from compiled workshop code',
            <div>Decompiling will extract pathmap saves from a workshop gamemode.
                <br/><br/>This currently cannot decompile custom rules.</div>,
            'Decompile',
            'Workshop code (Compiled gamemode code)',
            PF_WORKSHOP_SAVE_NAME,
            code => {
                return decompile(code);
            }),
        useTextConverterSection(
            'Convert old OSTW pathmaps',
            <div>Old OSTW pathmaps in the <code>json</code> format used by the <code>Pathmap</code> and <code>Bakemap</code> classes
                can be converted to be loaded by the pathmap editor.</div>,
            'Convert',
            'Pathmap json',
            PF_WORKSHOP_SAVE_NAME,
            code => {
                const map = loadFromOldJson(code);
                if (map instanceof Error) {
                    return errorToConvertResult(map);
                }
                return textToConvertResult(saveToWorkshop(map));
            })
    ];

    return (
        <div className="App">
            <header className="App-header">Pathmap editor save tool</header>
            <div className='App-content'>
                <div className='App-content-inner'>
                    <HeaderAndContent sections={SECTIONS} />
                </div>
            </div>
        </div>
    );
}

export default App;
