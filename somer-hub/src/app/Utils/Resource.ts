export class Resource {
    public ID: string       = "";
    public version: string  = "";
    public title: string    = "";
    public subtitle: string = "";
    public desc: string     = "";
    public longDesc: string = "";
    public deps: string[] = [];

    constructor(
        ID: string       = "",
        version: string  = "1.0.0",
        title: string    = "",
        subtitle: string = "",
        desc: string     = "",
        longDesc: string = "",
        deps: string[]   = []
    ) {
        ID           = ID,
        version      = version,
        title        = title,
        subtitle     = subtitle,
        desc         = desc,
        longDesc     = longDesc,
        deps         = deps
    }
}