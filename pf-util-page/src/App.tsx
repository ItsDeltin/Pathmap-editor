import React from 'react';
import './App.css';
import { AppSection, errorToConvertResult, textToConvertResult, useTextConverterSection } from './model/AppSection';
import HeaderAndContent from './HeaderAndContent';
import { parseActionSet } from './workshop/parseActionSet';
import loadFromWorkshop from './save/LoadFromWorkshop';
import loadFromOldJson from './save/LoadFromOldJson';
import { saveToWorkshop } from './save/PathmapSave';
import decompile from './save/Decompile';

export const currentVersion: number = 3;

function App() {
    const SECTIONS: AppSection[] = [
        useTextConverterSection(
            'Clean up and update save',
            <div>Saves copied from Overwatch may have a high element count or be outdated for current pathmap versions.</div>,
            'Clean',
            'Workshop code (Pathmap save)',
            'Workshop code (Cleaned)',
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
                // Load save
                const pathmap = loadFromWorkshop(workshop.actions, {log(text, type) {
                }
                });
                return textToConvertResult('');
            }
        ),
        useTextConverterSection(
            'Pathmap save from compiled workshop code',
            <div>Decompiling will extract pathmap saves from a workshop gamemode.
                <br/><br/>This currently cannot decompile custom rules.</div>,
            'Decompile',
            'Workshop code (Compiled pf code)',
            'Workshop code (Pathmap save)',
            code => {
                return decompile(code);
            }),
        useTextConverterSection(
            'Convert old OSTW pathmaps',
            <div>Old OSTW pathmaps in the <code>json</code> format used by the <code>Pathmap</code> and <code>Bakemap</code> classes
                can be converted to be loaded by the pathmap editor.</div>,
            'Convert',
            'Pathmap json',
            'Workshop code (Pathmap save)',
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
