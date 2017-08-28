# zendesk_oom_blog
This is the supplemental code for Swiftype's Zendesk OOM blog post

## Getting started

Install [JRuby](http://jruby.org/getting-started) and the [Java Memory Analyzer Tool](https://www.eclipse.org/mat/downloads.php?).

While in this repo's directory, check if you have bundler (`bundle --version` to check). If not, install bundler:

    gem install bundler

Install the required gems:

    bundle install

## Running the example

    bundle exec jirb zendesk_oom_example.rb
    
## Getting a heap dump

### Downloading it
I've included it in a [supplemental release](https://github.com/swiftype/zendesk_oom_blog/releases/tag/supplement) since it is over 100MB.

### Extract it yourself

Find the Process ID of the running JRuby process (you can throw a `binding.pry` at the end of the file if it runs too fast). Then run this command to grab the heap dump.
    
    jmap -dump:format=b,file=zendesk_oom_heap_dump.bin [pid]



