class VS_Package extends Object;

const PKG_AllowDownload  = 0x0001; // Allow downloading package.
const PKG_ClientOptional = 0x0002; // Purely optional for clients.
const PKG_ServerSideOnly = 0x0004; // Only needed on the server side.
const PKG_BrokenLinks    = 0x0008; // Loaded from linker with broken import links.
const PKG_Unsecure       = 0x0010; // Not trusted.
const PKG_RequireMD5     = 0x0020; // Server is requiring MD5 from the client.
const PKG_Need           = 0x8000; // Client needs to download this package.

var native const pointer DllHandle;
var native const bool AttemptedBind;
var native const int PackageFlags;
var native const string LastLoadedFrom;
