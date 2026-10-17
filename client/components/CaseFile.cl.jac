"""Case file card: the player's briefing (left panel, top)."""

def:pub CaseFile(title: str, setting: str, summary: str) -> JsxElement {
    return <section className="rounded-xl border bg-card p-4">
        <p className="text-xs font-bold tracking-[0.15em] text-primary">CASE FILE</p>
        <h2 className="mt-1 text-lg font-semibold">{title}</h2>
        <p className="mt-2 text-sm">
            <span className="font-semibold text-primary">Where: </span>{setting}
        </p>
        <p className="mt-2 text-sm">
            <span className="font-semibold text-primary">What happened: </span>{summary}
        </p>
        <p className="mt-2 text-sm">
            <span className="font-semibold text-primary">Your job: </span>Find who did it.
        </p>
    </section>;
}
