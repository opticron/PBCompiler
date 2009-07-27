module pbcompiler;
// compiler for .proto protocol buffer definition files that generates D code
import ProtocolBuffer.pbroot;
import std.file;
import std.string;
import std.path;
// our tree of roots to play with, so that we can apply multiple extensions to a given document
PBRoot[char[]]docroots;

int main(char[][]args) {
	// rip off the first arg, because that's the name of the program
	args = args[1..$];
	if (!args.length) throw new Exception("No proto files supplied on the command line!");
	foreach (arg;args) {
		readRoot(arg);
	}
	applyExtensions();
	writeRoots();
	return 0;
}

// returns package name
char[]readRoot(char[]filename) {
	char[]contents = cast(char[])read(filename);
	auto root = PBRoot(contents);
	char[]fname = root.Package;
	if (!fname.length) {
		if (filename.length>6 && filename[$-6..$].icmp(".proto") == 0) {
			fname = filename[0..$-6];
		} else {
			fname = filename;
		}
	}
	root.Package = fname;
	foreach(ref imp;root.imports) {
		imp = readRoot(imp);
	}
	// store this for later use under its package name
	docroots[root.Package] = root;
	return root.Package;
}

// we run through the whole list looking for extensions and applying them
void applyExtensions() {
	foreach(root;docroots) {
		// make sure something can only extend what it has access to
	}
}

// this is where all files are written, no real processing is done here
void writeRoots() {
	foreach(root;docroots) {
		char[]tmp;
		tmp = "module "~root.Package~";\n";
		// write out imports
		foreach(imp;root.imports) {
			tmp ~= "import "~imp~";\n";
		}
		tmp ~= root.toDString;
		char[]fname = root.Package.tr(".","/")~".d";
		char[]dname = fname.getDirName();
		// check to see if we need to create the directory
		if (dname.length && !dname.exists()) {
			dname.mkdirRecurse();
		}
		write(fname,tmp);
	}
}

void mkdirRecurse(in char[] pathname)
{
	char[]left = getDirName(pathname);
	exists(left) || mkdirRecurse(left);
	mkdir(pathname);
}
