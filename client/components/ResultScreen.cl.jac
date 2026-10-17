"""Result screen: verdict, true story, clues found, score and rank."""

sv import from game.types { Result, PublicClue }

def:pub ResultScreen(outcome: Result, clues: list[PublicClue], onPlayAgain: Callable[[], None]) -> JsxElement {
    def handle_again(_e: MouseEvent) {
        onPlayAgain();
    }

    verdictTone = "bg-green-600 text-white" if outcome.correct else "bg-destructive text-white";
    return <div className="flex min-h-svh items-center justify-center px-4 py-10">
        <div className="w-full max-w-2xl text-center">
            <span className={"inline-block rounded-full px-4 py-1.5 text-sm font-black tracking-[0.2em] " + verdictTone}>
                {"CASE SOLVED" if outcome.correct else "WRONG SUSPECT"}
            </span>
            <div className="mt-6 flex justify-center gap-3">
                <div className="min-w-36 rounded-xl border bg-card px-5 py-3">
                    <p className="text-xs font-bold tracking-[0.15em] text-primary">SCORE</p>
                    <p className="text-4xl font-black">{outcome.score}</p>
                </div>
                <div className="min-w-36 rounded-xl border bg-card px-5 py-3">
                    <p className="text-xs font-bold tracking-[0.15em] text-primary">RANK</p>
                    <p className="text-xl font-bold text-primary">{outcome.rank if outcome.rank else "Rookie"}</p>
                </div>
            </div>
            <section className="mt-6 rounded-xl border bg-card p-5 text-left">
                <p className="text-xs font-bold tracking-[0.15em] text-primary">WHAT REALLY HAPPENED</p>
                <p className="mt-2 leading-relaxed">{outcome.story}</p>
            </section>
            {len(clues) > 0 and <section className="mt-4 rounded-xl border bg-card p-5 text-left">
                <p className="text-xs font-bold tracking-[0.15em] text-primary">CLUES YOU FOUND</p>
                <ul className="mt-2 list-disc space-y-1 pl-5">
                    {for c in clues {
                        <li key={c.id}>{c.text}</li>
                    }}
                </ul>
            </section>}
            <button
                className="mt-8 rounded-lg bg-primary px-8 py-3 text-lg font-semibold text-primary-foreground hover:bg-primary/85"
                onClick={handle_again}
            >
                Play Again
            </button>
        </div>
    </div>;
}
