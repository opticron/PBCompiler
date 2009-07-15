module pbcompiler;
// compiler for .proto protocol buffer definition files that generates D code
import ProtocolBuffer.pbroot;
import std.file;
import std.string;
int main(char[][]args) {
	// rip off the first arg, because that's the name of the program
	args = args[1..$];
	if (!args.length) throw new Exception("No proto files supplied on the command line!");
	foreach (arg;args) {
		char[]contents = cast(char[])read(arg);
		auto root = PBRoot(contents);
		char[]fname = root.Package;
		if (!fname.length) {
			if (arg.length>6 && arg[$-6..$].icmp(".proto") == 0) {
				fname = arg[0..$-6]~".d";
				// we want to grab the name here
			} else {
				fname = arg~".d";
			}
		} else {
			fname ~= ".d";
		}
		write(fname,root.toDString);
	}
	return 0;
}
