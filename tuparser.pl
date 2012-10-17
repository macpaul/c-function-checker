#!/usr/bin/perl

use GCC::TranslationUnit;

# echo '#include <stdio.h>' > stdio.c
# gcc -fdump-translation-unit -c stdio.c

sub list_param {
	my ($param);
	($param) = @_;
	my $name;
	
	printf "%s ",
		gettype($param->type);

	if ($param) {
		$name = $param->name->identifier;
		printf "%s", $name;
	} else {
		printf " ";
	}

	if ($param->chain) {
		printf ", ";
		list_param($param->chain);
	}
}

sub gettype {
	my ($type);
	($type) = @_;

	if ($type->isa('GCC::Node::void_type')) {
		return 'void';
	} elsif ($type->isa('GCC::Node::integer_type')) {
		return $type->name->name->identifier;
	} elsif ($type->isa('GCC::Node::pointer_type')) {
		return gettype($type->ptd) . '*';
	} elsif ($type->isa('GCC::Node::record_type')) {
		return 'struct ' . gettype($type->name->identifier);
	} elsif ($type->isa('GCC::Node::enumeral_type')) {
		return 'enum ' . gettype($type->name->identifier);
	} else {
		return $type; #todo
	}
}

my $node;
$node = GCC::TranslationUnit::Parser->parsefile($ARGV[0])->root;

my $file;
$file = $ARGV[0];
$file =~ s/.001t.tu//;

# list every function/variable name
while($node) {
	my $ret;

	if($node->isa('GCC::Node::function_decl')) {
		if ($node->source =~ /$file/) {
			$ret = $node->type->retn;

			printf "%s %s(",
				gettype($ret), $node->name->identifier;

			if (defined($node->args) and 
				$node->args->isa('GCC::Node::parm_decl')) {
				list_param($node->args);
				printf ") ";
			} else {
				printf ") ";
			}
			printf "in %s\n",
				$node->source;
		}
	}
} continue {
	#print $node;
	$node = $node->chain;
}
