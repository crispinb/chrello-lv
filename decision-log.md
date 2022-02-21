* replace Mox with Bypass
  + problem
    *  as the api client implements the HTTPoison. Base behaviour, 
    tests of modules that depend on the client also must depend on HTTPoison.
    This leaks too much into the test. 
  * options
    * rewrite the api client's own api as behaviour or protocol, and mock that
    * use Bypass in tests to trasparently supply HTTPoison with the data
  * solution
    * Bypass. No great reasoning - less rewriting, & I wanted to try it out. Has disadvantage that we need to add a bit of config to supply the bypass stub url & port to the client (previously built into Base callback module)