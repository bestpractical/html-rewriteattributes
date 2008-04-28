use inc::Module::Install;

# Define metadata
name            'HTML-RewriteResources';
all_from        'lib/HTML/RewriteResources.pm';

requires 'HTML::Parser';

WriteAll;

