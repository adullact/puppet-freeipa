If you follow these contributing guidelines your patch
will likely make it into a release a little more quickly.

## Contributing

1. Fork the repo.

2. Create a separate branch for your change.

3. We only take pull requests with passing tests, and documentation. You can also execute them locally. 

4. Checkout [Voxpupuli review docs](https://voxpupuli.org/docs/#reviewing-a-module-pr). We try to 
   use it to review a merge request and the [official styleguide](https://puppet.com/docs/puppet/6.0/style_guide.html).
   They provide some guidance for new code that might help you before you submit a merge request.

5. Add a test for your change. Only refactoring and documentation
   changes require no new tests. If you are adding functionality
   or fixing a bug, please add a test.

6. Squash your commits down into logical components. Make sure to rebase
   against our current master.

7. Push the branch to your fork and submit a merge request.

Please be prepared to repeat some of these steps as your code is reviewed.

