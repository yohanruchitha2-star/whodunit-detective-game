"""Start screen + "Generating your case..." state, as a case folder on the board."""

import from .Board { Board, TapeLabel, Paper, hand }

def:pub LevelCard(level: str, title: str, blurb: str, selected: str, tilt: str, onSelect: Callable[[str], None]) -> JsxElement {
    def handle_click(_e: MouseEvent) {
        onSelect(level);
    }

    picked = selected == level;
    tone = "bg-[#fde68a] ring-4 ring-[#8a2d1d]/70" if picked else "bg-[#fdf6e3] hover:-translate-y-0.5";
    return <button className={"relative p-3 text-left text-[#231a12] shadow-md transition " + tone + " " + tilt} onClick={handle_click}>
        <span className="block text-2xl font-bold" style={hand()}>{title}</span>
        <span className="mt-1 block text-xs text-[#5a4a3a]">{blurb}</span>
    </button>;
}

def:pub StartScreen(
    loading: bool,
    loadingMsg: str,
    errorMsg: str,
    selected: str,
    onSelect: Callable[[str], None],
    onStart: Callable[[str], None]
) -> JsxElement {
    def handle_start(_e: MouseEvent) {
        onStart(selected);
    }

    return <Board>
        <div className="mx-auto flex max-w-3xl flex-col items-center gap-8 pt-6 sm:pt-12">
            <TapeLabel text="Whodunit" big={True} tilt="-rotate-2" />
            <Paper className="w-full max-w-2xl px-6 py-6 sm:px-10" tilt="rotate-[0.5deg]">
                <p className="text-center text-xl font-semibold" style={hand()}>
                    A new Sri Lankan mystery every time. Question the suspects, catch a liar, solve the case.
                </p>
                <div className="mt-6 flex min-h-24 flex-col items-center justify-center gap-4" aria-live="polite">
                    {if loading {
                        <div className="size-10 animate-spin rounded-full border-4 border-[#e5d5b5] border-t-[#8a2d1d]"></div>
                        <p className="text-2xl font-bold text-[#8a2d1d]" style={hand()}>{loadingMsg}</p>
                    } else {
                        <div className="grid w-full grid-cols-1 gap-4 sm:grid-cols-3">
                            <LevelCard level="easy" title="Easy" blurb="3 suspects, cheap hints, 3 guesses, score x0.8" selected={selected} tilt="-rotate-1" onSelect={onSelect} />
                            <LevelCard level="normal" title="Normal" blurb="4 suspects, 2 guesses, score x1" selected={selected} tilt="rotate-1" onSelect={onSelect} />
                            <LevelCard level="hard" title="Hard" blurb="5 suspects, evasive, 1 hint, 1 guess, score x1.5" selected={selected} tilt="-rotate-1" onSelect={onSelect} />
                        </div>
                        <button
                            className="rounded-sm bg-[#8a2d1d] px-10 py-3 text-2xl font-bold text-[#fdf6e3] shadow-lg transition hover:bg-[#a33a27]"
                            style={hand()}
                            onClick={handle_start}
                        >
                            Open a New Case
                        </button>
                    }}
                </div>
                {errorMsg and <p className="mt-4 text-center font-semibold text-red-700">{errorMsg}</p>}
            </Paper>
            <Paper className="w-full max-w-md" tilt="-rotate-1">
                <p className="mb-1 text-2xl font-bold" style={hand()}>How to play</p>
                <ol className="list-decimal space-y-1 pl-5 text-sm">
                    <li>Read the case file pinned to the board.</li>
                    <li>Click a suspect's photo to question them. Clues land in your notebook.</li>
                    <li>Show a clue to the right suspect to break their lie.</li>
                    <li>Accuse the culprit. Fewer questions means a higher score.</li>
                </ol>
            </Paper>
        </div>
    </Board>;
}
