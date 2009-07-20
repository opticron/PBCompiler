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
		compileRoot(arg);
	}
	return 0;
}

// returns package name
char[]compileRoot(char[]filename) {
	char[]contents = cast(char[])read(filename);
	auto root = PBRoot(contents);
	char[]fname = root.Package;
	if (!fname.length) {
		if (filename.length>6 && filename[$-6..$].icmp(".proto") == 0) {
			fname = filename[0..$-6]~".d";
			// we want to grab the name here
		} else {
			fname = filename~".d";
		}
	}
	char[]tmp;
	tmp ~= "module "~fname~";\n";
	foreach(imp;root.imports) {
		tmp ~= "import "~compileRoot(imp)~";\n";
	}
	tmp ~= root.toDString;
	fname ~= ".d";
	write(fname,tmp);
	return fname[0..$-2];
}
