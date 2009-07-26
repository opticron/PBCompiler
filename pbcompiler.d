module pbcompiler;
// compiler for .proto protocol buffer definition files that generates D code
import ProtocolBuffer.pbroot;
import std.file;
import std.string;
import std.path;

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
	// convert fname to a real path, .->/
	fname = fname.tr(".","/");
	fname ~= ".d";
	char[]dname = fname.getDirName();
	// check to see if we need to create the directory
	if (dname.length && !dname.exists()) {
		dname.mkdirRecurse();
	}
	write(fname,tmp);
	return fname[0..$-2];
}

void mkdirRecurse(in char[] pathname)
{
	char[]left = getDirName(pathname);
	exists(left) || mkdirRecurse(left);
	mkdir(pathname);
}
