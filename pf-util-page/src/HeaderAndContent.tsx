import React from "react";
import { AppSection } from "./model/AppSection";
import HeaderSelector from "./HeaderSelector";

type HeaderAndContentProps = {
    sections: AppSection[]
};

const HeaderAndContent: React.FC<HeaderAndContentProps> = ({ sections }) => {
    const [selected, setSelected] = React.useState(0);

    return <div>
        <HeaderSelector sections={sections.map(s => s.title)} selected={selected} setSelected={setSelected} />
        <div className='Section-content'>{sections[selected].content}</div>
    </div>
};

export default HeaderAndContent;