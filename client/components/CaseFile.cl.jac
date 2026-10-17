"""Case file note pinned to the board (left column)."""

import from .Board { Paper, hand }

def:pub CaseFile(title: str, setting: str, summary: str) -> JsxElement {
    return <Paper className="max-h-[60vh] overflow-y-auto" tilt="rotate-1">
        <p className="text-2xl font-bold" style={hand()}>{title}</p>
        <p className="mt-3 text-sm leading-relaxed">
            <span className="font-bold text-[#8a2d1d]">Where: </span>{setting}
        </p>
        <p className="mt-2 text-sm leading-relaxed">
            <span className="font-bold text-[#8a2d1d]">What happened: </span>{summary}
        </p>
        <p className="mt-2 text-sm leading-relaxed">
            <span className="font-bold text-[#8a2d1d]">Your job: </span>Find who did it.
        </p>
    </Paper>;
}
