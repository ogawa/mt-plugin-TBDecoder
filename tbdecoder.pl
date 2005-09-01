# A plugin for decoding incoming tbpings into PublishCharset
#
# $Id$
#
# This software is provided as-is. You may use it for commercial or 
# personal use. If you distribute it, please keep this notice intact.
#
# Copyright (c) 2005 Hirotaka Ogawa

package MT::Plugin::TBDecoder;
use strict;
use MT;
use vars qw($VERSION);

$VERSION = '0.01';

my $plugin;
eval {
    require MT::Plugin;
    $plugin = new MT::Plugin({
	name => 'TBDecoder',
	description => "Decode incoming tbpings into PublishCharset",
	doc_link => 'http://as-is.net/hacks/2005/09/tbdecoder_plugin.html',
	author_name => 'Hirotaka Ogawa',
	author_link => 'http://profile.typekey.com/ogawa/',
	version => $VERSION
	});
    MT->add_plugin($plugin);
};

if (MT->can('add_callback') && ref MT->instance eq 'MT::App::Trackback') {
    MT->add_callback('MT::TBPing::pre_save', 10, $plugin, \&tbdecoder);
}

use MT::ConfigMgr;
use Encode qw(encode);
use Encode::Guess qw(euc-jp shiftjis 7bit-jis);

sub tbdecoder {
    my ($cb, $obj, $original) = @_;
    my ($blog_name, $title, $excerpt) = ($obj->blog_name, $obj->title, $obj->excerpt);
    my $decoder = Encode::Guess->guess($blog_name.$title.$excerpt);
    return unless ref $decoder;
    my $enc = MT::ConfigMgr->instance->PublishCharset || 'utf8';
    $blog_name = encode($enc, $decoder->decode($blog_name));
    $title = encode($enc, $decoder->decode($title));
    $excerpt = encode($enc, $decoder->decode($excerpt));
    $obj->blog_name($blog_name);
    $obj->title($title);
    $obj->excerpt($excerpt);
}

1;
__END__
