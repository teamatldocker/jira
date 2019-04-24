# Contributing to teamatldocker/jira

:+1::tada: First off, thanks for taking the time to contribute! :tada::+1:

The following is a set of guidelines for contributing to teamatldocker/jira These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## I don't want to read this whole thing I just have a question!!!

Open an issue on the repository!

## How Can I Contribute?

### Reporting Bugs

Before Submitting A Bug Report:

* Check the Issues section of the repository.
* Use a clear and descriptive title for the issue to identify the problem.
* Describe the exact steps which reproduce the problem in as many details as possible.
* Explain which behavior you expected to see instead and why.
* Include logs & details about your configuration and environment

### Pull Requests

* Only open pull requests on the master branch!
* Fill in the required template!
* All pull requests require testing:

  1. Build the image.
  1. Start the image in your environment and test expected behavior.
  1. Only PR if your feature is fully functional.

Build the image:

~~~~
$ docker build -t teamatldocker/jira .
~~~~
