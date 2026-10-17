"""Corkboard look: wooden frame, taped labels, paper notes and suspect polaroids."""

import from .Photos { photo_for }

glob HAND: dict[str, str] = {"fontFamily": "'Caveat', 'Segoe Print', 'Comic Sans MS', cursive"};
glob PHOTO_COLORS: list[str] = ["bg-[#7c5c46]", "bg-[#55697a]", "bg-[#6b7a52]", "bg-[#87566a]", "bg-[#7a6640]"];
glob TILTS: list[str] = ["-rotate-2", "rotate-1", "rotate-2", "-rotate-1", "rotate-1"];

# Handwritten font style, exported as a function (globs are not exported across client modules).
def:pub hand() -> dict[str, str] {
    return HAND;
}

# The whole page: dark wall, wooden frame, kraft-paper board.
def:pub Board(children: any = None) -> JsxElement {
    return <div className="min-h-svh bg-[#21170f] p-2 sm:p-3">
        <div
            className="relative min-h-[calc(100svh-1.5rem)] rounded-md border-[10px] border-[#4a3426] px-4 py-6 shadow-[inset_0_0_60px_rgba(0,0,0,0.35)] sm:px-8"
            style={{"background": "radial-gradient(ellipse at 30% 20%, #c79b6e 0%, #b3865c 45%, #9a6f48 100%)"}}
        >
            {children}
        </div>
    </div>;
}

# A strip of tape (decoration).
def:pub Tape(className: str = "") -> JsxElement {
    return <span className={"pointer-events-none absolute h-5 w-14 bg-white/45 shadow-sm " + className}></span>;
}

# Handwritten label on a taped paper strip, like "Suspects".
def:pub TapeLabel(text: str, big: bool = False, tilt: str = "-rotate-1") -> JsxElement {
    size = "text-4xl sm:text-5xl px-5 py-2" if big else "text-2xl sm:text-3xl px-4 py-1";
    return <div className={"relative inline-block bg-[#fdf6e3] text-[#231a12] shadow-md " + tilt}>
        <Tape className="-left-4 -top-2 -rotate-45" />
        <Tape className="-right-4 -bottom-2 -rotate-45" />
        <span className={"block font-bold " + size} style={HAND}>{text}</span>
    </div>;
}

# A taped paper note.
def:pub Paper(children: any = None, className: str = "", tilt: str = "") -> JsxElement {
    return <div className={"relative bg-[#fdf6e3] p-4 text-[#2b2118] shadow-lg " + tilt + " " + className}>
        <Tape className="-top-3 left-1/2 -translate-x-1/2 rotate-2" />
        {children}
    </div>;
}

# Big ink stamp, e.g. CRACKED or CASE CLOSED.
def:pub Stamp(text: str, good: bool = False, className: str = "") -> JsxElement {
    tone = "border-green-700 text-green-700" if good else "border-red-700 text-red-700";
    return <span className={"inline-block rotate-[-8deg] border-4 px-3 py-0.5 font-black uppercase tracking-[0.2em] opacity-85 " + tone + " " + className}>
        {text}
    </span>;
}

# The "photo" part of a polaroid: a stock photo picked from the role (Photos.cl.jac),
# with the suspect's initial on a coloured square behind it as the fallback.
def:pub PhotoBox(name: str, idx: int, role: str = "", className: str = "") -> JsxElement {
    has broken: bool = False;

    def handle_error(_e: Event) {
        broken = True;
    }

    color = PHOTO_COLORS[idx % len(PHOTO_COLORS)];
    src = photo_for(name, role, idx);
    return <div className={"relative flex aspect-square w-full items-center justify-center overflow-hidden " + color + " " + className}>
        <span className="text-7xl font-bold text-[#fdf6e3]/90" style={HAND}>{name[0] if name else "?"}</span>
        {not broken and <img
            className="absolute inset-0 h-full w-full object-cover sepia-[0.25]"
            src={src}
            alt={name}
            loading="lazy"
            onError={handle_error}
        />}
    </div>;
}

# One suspect polaroid on the board. Click it to open the interrogation.
def:pub Polaroid(
    sid: str,
    name: str,
    role: str,
    style: str,
    idx: int,
    isCracked: bool,
    onOpen: Callable[[str], None]
) -> JsxElement {
    def handle_click(_e: MouseEvent) {
        onOpen(sid);
    }

    tilt = TILTS[idx % len(TILTS)];
    return <button
        className={"group relative w-full bg-[#fdf6e3] p-2.5 pb-3 text-left shadow-lg transition hover:z-10 hover:-translate-y-1 hover:rotate-0 hover:shadow-2xl " + tilt}
        onClick={handle_click}
        title={"Question " + name}
    >
        <Tape className="-top-3 left-1/2 -translate-x-1/2 -rotate-3" />
        <PhotoBox name={name} idx={idx} role={role} />
        <span className="mt-2 block text-lg font-bold text-[#231a12]">{name}</span>
        <span className="block text-sm text-[#5a4a3a]">{role + ((" · " + style) if style else "")}</span>
        {isCracked and <span className="absolute right-2 top-6">
            <Stamp text="Cracked" className="text-lg" />
        </span>}
    </button>;
}
