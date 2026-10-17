"""Result screen: case-closed stamp, score/difficulty/rank, true story and the clues."""

import from .Board { Board, TapeLabel, Paper, Stamp, hand }

sv import from game.types { AccuseOut, PublicClue }

def:pub ResultScreen(outcome: AccuseOut, clues: list[PublicClue], onPlayAgain: Callable[[], None]) -> JsxElement {
    def handle_again(_e: MouseEvent) {
        onPlayAgain();
    }

    culpritName = outcome.culprit.name if outcome.culprit is not None and outcome.culprit.name else "";
    return <Board>
        <div className="mx-auto flex max-w-3xl flex-col items-center gap-6 pt-4">
            <TapeLabel text="Case File: Closed" big={True} tilt="-rotate-1" />
            <Stamp text={"Case solved" if outcome.correct else "Wrong suspect"} good={outcome.correct} className="bg-[#fdf6e3]/80 text-3xl sm:text-4xl" />
            {culpritName and <p className="text-3xl font-bold text-[#231a12]" style={hand()}>
                {"The culprit was " + culpritName + "."}
            </p>}
            <div className="grid w-full grid-cols-3 gap-4">
                <Paper className="text-center" tilt="-rotate-2">
                    <p className="text-lg font-bold" style={hand()}>Score</p>
                    <p className="text-4xl font-black text-[#8a2d1d]">{outcome.score}</p>
                </Paper>
                <Paper className="text-center" tilt="rotate-1">
                    <p className="text-lg font-bold" style={hand()}>Difficulty</p>
                    <p className="text-2xl font-bold capitalize">{outcome.difficulty}</p>
                    <p className="text-xs text-[#5a4a3a]">{"score x" + str(outcome.multiplier)}</p>
                </Paper>
                <Paper className="text-center" tilt="rotate-2">
                    <p className="text-lg font-bold" style={hand()}>Rank</p>
                    <p className="text-2xl font-bold text-[#8a2d1d]">{outcome.rank if outcome.rank else "Rookie"}</p>
                </Paper>
            </div>
            <Paper className="w-full" tilt="rotate-[0.5deg]">
                <p className="text-2xl font-bold" style={hand()}>What really happened</p>
                <p className="mt-2 leading-relaxed">{outcome.story}</p>
            </Paper>
            {len(clues) > 0 and <Paper className="w-full" tilt="-rotate-1">
                <p className="text-2xl font-bold" style={hand()}>Clues you found</p>
                <ul className="mt-1 list-disc space-y-1 pl-5 text-sm">
                    {for c in clues {
                        <li key={c.id}>{c.text}</li>
                    }}
                </ul>
            </Paper>}
            <button
                className="rounded-sm bg-[#8a2d1d] px-10 py-3 text-2xl font-bold text-[#fdf6e3] shadow-lg hover:bg-[#a33a27]"
                style={hand()}
                onClick={handle_again}
            >
                Play Again
            </button>
        </div>
    </Board>;
}
