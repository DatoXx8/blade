const std = @import("std");
const assert = std.debug.assert;

pub inline fn maybe(ok: bool) void {
    assert(ok or !ok);
}
