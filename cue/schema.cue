package sutliff

// ── User (renamed from Persona) ─────────────────────────────────────────

#UserID: =~"^[a-z][a-z0-9_]*$"

#User: {
    id:        #UserID
    display:   string
    title:     string
    archetype: string
    tagline:   string
    bio:       string
    style:     string
    catchphrase: string
    pronouns:  string
    joined:    string
    role:      string
    avatar:    string
    color:     string
    signature: string
    posts:     int
    post_rate: float
    expertise: [...string]
    quirks:    [...string]
    badge?:    string
}

// ── Posts ───────────────────────────────────────────────────────────────

#Post: {
    user:      #UserID
    timestamp: string
    body:      string
    quote?:    #UserID
}

// ── Threads ─────────────────────────────────────────────────────────────

#Category: "opinion" | "tutorial" | "reference" | "daily"

#Thread: {
    id:    string
    title: string
    date:  string
    tags:  [...string]
    category: #Category
    slug:     string | *id
    starter:  #UserID
    posts:    [...#Post]
    description?: string
}

// ── Content store ───────────────────────────────────────────────────────

#ContentStore: {
    users:   { [string]: #User }
    threads: { [string]: #Thread }
}
