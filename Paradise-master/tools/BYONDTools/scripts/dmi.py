#!/usr/bin/env python
"""
DMI SPLITTER-UPPER THING

Makes merging sprites a hell of a lot easier.
by N3X15 <nexis@7chan.org>

Requires PIL
Written for Python 2.7.
"""

import sys, os, traceback, fnmatch, argparse

from byond.DMI import DMI

args = ()
	
def main():
	opt = argparse.ArgumentParser()  # version='0.1')
	opt.add_argument('-p', '--suppress-post-processing', dest='suppress_post_process', default=False, action='store_true')
	command = opt.add_subparsers(help='The command you wish to execute', dest='MODE')
	
	_disassemble = command.add_parser('disassemble', help='Disassemble a single DMI file to a destination directory')
	_disassemble.add_argument('file', type=str, help='The DMI file to disassemble.', metavar='file.dmi')
	_disassemble.add_argument('destination', type=str, help='The directory in which to dump the resulting images.', metavar='dest/')
	
	_disassemble_all = command.add_parser('disassemble-all', help='Disassemble a directory of DMI files to a destination directory')
	_disassemble_all.add_argument('source', type=str, help='The DMI files to disassemble.', metavar='source/')
	_disassemble_all.add_argument('destination', type=str, help='The directory in which to dump the resulting images.', metavar='dest/')
	
	_compile = command.add_parser('compile', help='Compile a .dmi.mak file')
	_compile.add_argument('makefile', type=str, help='The .dmi.mak file to compile.', metavar='file.dmi.mak')
	_compile.add_argument('destination', type=str, help='The location of the resulting .dmi file.', metavar='file.dmi')
	
	_compare = command.add_parser('compare', help='Compare two DMI files and note the differences')
	_compare.add_argument('theirs', type=str, help='One side of the difference', metavar='theirs.dmi')
	_compare.add_argument('mine', type=str, help='The other side.', metavar='mine.dmi')
	
	_compare_all = command.add_parser('compare-all', help='Compare two DMI file directories and note the differences')
	_compare_all.add_argument('theirs', type=str, help='One side of the difference', metavar='theirs/')
	_compare_all.add_argument('mine', type=str, help='The other side.', metavar='mine/')
	_compare_all.add_argument('report', type=str, help='The file the report is saved to', metavar='report.txt')
	
	_get_dmi_data = command.add_parser('get-dmi-data', help='Extract DMI header')
	_get_dmi_data.add_argument('file', type=str, help='DMI file', metavar='file.dmi')
	_get_dmi_data.add_argument('dest', type=str, help='The file where the DMI header will be saved', metavar='dest.txt')
	
	_set_dmi_data = command.add_parser('set-dmi-data', help='Set DMI header')
	_set_dmi_data.add_argument('file', type=str, help='One side of the difference', metavar='file.dmi')
	_set_dmi_data.add_argument('metadata', type=str, help='DMI header file', metavar='metadata.txt')
	
	_set_dmi_data = command.add_parser('clean', help='Clean up temporary files and *.new.dmi files.')
	_set_dmi_data.add_argument('basedir', type=str, help='Starting directory', metavar='vgstation/')
	
	args = opt.parse_args()
	#print(args)
	if args.MODE == 'compile':
		make_dmi(args.makefile, args.destination, args)
	if args.MODE == 'compare':
		compare(args.theirs, args.mine, args, sys.stdout)
	if args.MODE == 'compare-all':
		compare_all(args.theirs, args.mine, args.report, args)
	elif args.MODE == 'disassemble':
		disassemble(args.file, args.destination, args)
	elif args.MODE == 'disassemble-all':
		disassemble_all(args.source, args.destination, args)
	elif args.MODE == 'get-dmi-data':
		get_dmi_data(args.file, args.dest, args)
	elif args.MODE == 'set-dmi-data':
		set_dmi_data(args.file, args.metadata, args)
	elif args.MODE == 'cleanup':
		cleanup(args.basedir, args)
	else:
		print('!!! Error, unknown MODE=%r' % args.MODE)



class ModeAction(argparse.Action):
	def __call__(self, parser, namespace, values, option_string=None):
		# print('%s %s %s' % (namespace, values, option_string))
		namespace.MODE = self.dest
		namespace.args = values

def get_dmi_data(path, dest, parser):
	if(os.path.isfile(path)):
		dmi = DMI(path)
		with open(dest, 'w') as f:
			f.write(dmi.getHeader())
				
def set_dmi_data(path, headerFile, parser):
	if(os.path.isfile(path)):
		dmi = DMI(path)
		with open(headerFile, 'r') as f:
			dmi.setHeader(f.read(), path)

def make_dmi(path, dest, parser):
	if(os.path.isfile(path)):
		dmi = None
		try:
			dmi = DMI(dest)
			dmi.make(path)
			dmi.save(dest)
		except SystemError as e:
			print("!!! Received SystemError in %s, halting: %s" % (dmi.filename, traceback.format_exc(e)))
			print('# of cells: %d' % len(dmi.states))
			print('Image h/w: %s' % repr(dmi.size))
			sys.exit(1)
		except Exception as e:
			print("Received error, continuing: %s" % traceback.format_exc())

def disassemble(path, to, parser):
	print('\tD %s -> %s' % (path, to))
	if(os.path.isfile(path)):
		dmi = None
		try:
			dmi = DMI(path)
			dmi.extractTo(to, parser.suppress_post_process)
		except SystemError as e:
			print("!!! Received SystemError in %s, halting: %s" % (dmi.filename, traceback.format_exc(e)))
			print('# of cells: %d' % len(dmi.states))
			print('Image h/w: %s' % repr(dmi.size))
			sys.exit(1)
		except Exception as e:
			print("Received error, continuing: %s" % traceback.format_exc())

def compare(theirsfile, minefile, parser, reportstream, **kwargs):
	# print('\tD %s -> %s' % (theirsfile, minefile))
	theirs = []
	theirsDMI = None
	mine = []
	mineDMI = None
	states = []
	
	new2mineFilename = minefile.replace('.dmi', '.new.dmi')
	new2theirsFilename = theirsfile.replace('.dmi', '.new.dmi')
	
	new2mine=None
	if os.path.isfile(new2mineFilename):
		os.remove(new2mineFilename)
	if kwargs.get('newfile_mine',True):
		new2mine = DMI(new2mineFilename)
	
	new2theirs=None
	if os.path.isfile(new2theirsFilename):
		os.remove(new2theirsFilename)
	if kwargs.get('newfile_theirs',False):
		new2theirs = DMI(new2theirsFilename)
	
	
	o = ''
	if(os.path.isfile(theirsfile)):
		try:
			theirsDMI = DMI(theirsfile)
			theirsDMI.loadAll()
			theirs = theirsDMI.states
		except SystemError as e:
			print("!!! Received SystemError in %s, halting: %s" % (theirs.filename, traceback.format_exc(e)))
			print('# of cells: %d' % len(theirs.states))
			print('Image h/w: %s' % repr(theirs.size))
			sys.exit(1)
		except Exception as e:
			print("Received error, continuing: %s" % traceback.format_exc())
			o += "\n {0}: Received error, continuing: {1}".format(theirsfile, traceback.format_exc())
		for stateName in theirs:
			if stateName not in states:
				states.append(stateName)
	if(os.path.isfile(minefile)):
		try:
			mineDMI = DMI(minefile)
			mineDMI.loadAll()
			mine = mineDMI.states
		except SystemError as e:
			print("!!! Received SystemError in %s, halting: %s" % (mine.filename, traceback.format_exc(e)))
			print('# of cells: %d' % len(mine.states))
			print('Image h/w: %s' % repr(mine.size))
			sys.exit(1)
		except Exception as e:
			print("Received error, continuing: %s" % traceback.format_exc())
			o += "\n {0}: Received error, continuing: {1}".format(minefile, traceback.format_exc())
		for stateName in mine:
			if stateName not in states:
				states.append(stateName)
	for state in sorted(states):
		inTheirs = state in theirs
		inMine = state in mine 
		if inTheirs and not inMine:
			o += '\n + {1}'.format(minefile, state)
			if new2mine is not None:
				new2mine.states[state] = theirsDMI.states[state]
		elif not inTheirs and inMine:
			o += '\n - {1}'.format(theirsfile, state)
			if new2theirs is not None:
				new2theirs.states[state] = mineDMI.states[state]
		elif inTheirs and inMine:
			if theirs[state].ToString() != mine[state].ToString():
				o += '\n - {0}: {1}'.format(mine[state].displayName(), mine[state].ToString())
				o += '\n + {0}: {1}'.format(theirs[state].displayName(), theirs[state].ToString())
			elif kwargs.get('check_changed',True):
				diff_count=0
				for i in xrange(len(theirs[state].icons)):
					theirF = theirs[state].icons[i]
					myF = theirs[state].icons[i] 
					
					theirData = list(theirF.getdata())
					myData = list(myF.getdata())
					#diff = []
					
					for i in xrange(len(theirData)):
						dr = theirData[i][0] - myData[i][0]
						dg = theirData[i][1] - myData[i][1]
						db = theirData[i][2] - myData[i][2]
						#diff[idx] = (abs(dr), abs(dg), abs(db))
						if((dr != 0) or (dg != 0) or (db != 0)):
							diff_count += 1
							break
				if diff_count > 0:
					o += '\n ! {0}: {1} frames differ'.format(theirs[state].displayName(), diff_count)
					if new2mine is not None:
						new2mine.states[state] = theirsDMI.states[state]
					if new2theirs is not None:
						new2theirs.states[state] = mineDMI.states[state]
	if o != '': 
		reportstream.write('\n--- {0}'.format(theirsfile))
		reportstream.write('\n+++ {0}'.format(minefile))
		reportstream.write(o)
		
		if new2mine is not None:
			if len(new2mine.states) > 0:
				new2mine.save(new2mineFilename)
			else:
				if os.path.isfile(new2mineFilename):
					os.remove(new2mineFilename)
					#print('RM {0}'.format(new2mineFilename))
		if new2theirs is not None:
			if len(new2theirs.states) > 0:
				new2theirs.save(new2theirsFilename)
			else:
				if os.path.isfile(new2theirsFilename):
					os.remove(new2theirsFilename)
					#print('RM {0}'.format(new2theirsFilename))
					
def cleanup(subject):
	print('Cleaning...')
	for root, _, filenames in os.walk(subject):
		for filename in fnmatch.filter(filenames, '*.new.dmi'):
			path = os.path.join(root, filename)
			print('RM {0}'.format(path))
			os.remove(path)

def disassemble_all(in_dir, out_dir, parser):
	print('D_A %s -> %s' % (in_dir, out_dir))
	for root, dirnames, filenames in os.walk(out_dir):
		for filename in fnmatch.filter(filenames, '*.new.dmi'):
			path = os.path.join(root, filename)
			print('RM {0}'.format(path))
			os.remove(path)
	for root, dirnames, filenames in os.walk(in_dir):
		for filename in fnmatch.filter(filenames, '*.dmi'):
			path = os.path.join(root, filename)
			to = os.path.join(out_dir, path.replace(in_dir, '').replace(os.path.basename(path), ''))
			disassemble(path, to, parser)
	

def compare_all(in_dir, out_dir, report, parser, **kwargs):
	with open(report, 'w') as report:
		report.write('# DMITool Difference Report: {0} {1}'.format(os.path.abspath(in_dir), os.path.abspath(out_dir)))
		for root, dirnames, filenames in os.walk(in_dir):
			for filename in fnmatch.filter(filenames, '*.dmi'):
				path = os.path.join(root, filename)
				to = os.path.join(out_dir, path.replace(in_dir, '').replace(os.path.basename(path), ''))
				to = os.path.join(to, filename)
				path = os.path.abspath(path)
				to = os.path.abspath(to)
				compare(path, to, parser, report, **kwargs)


if __name__ == '__main__':
	main()
