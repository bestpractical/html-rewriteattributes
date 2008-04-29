use inc::Module::Install;

# Define metadata
name            'HTML-RewriteAttributes';
all_from        'lib/HTML/RewriteAttributes.pm';

requires 'HTML::Parser';
requires 'HTML::Entities';

WriteAll;

