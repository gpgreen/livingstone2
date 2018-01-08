Various tests for Combat.

Say "make test" to run all tests, or run "dotest" in each subdirectory.

The following tests are known to fail:

- 1/

  - ptypes-1.3, ptypes-2.3, ptypes-3.3, ptypes-4.3:

    These tests check that values which exceed a type's range are rejected,
    e.g., attempting to pass the value 32768 as an "unsigned short".  However,
    Combat doesn't check a type's range yet, and therefore the test fails.

- 3/

  - unions-1.4

    Fails for the same reason as above.

- 8/

  - All these tests fail because Combat does not implement the Dynamic
    Skeleton Interface (DSI).

- 9/

  - This test requires access to an empty CORBA Naming Service.  The test
    can be run manually by providing an initial reference to a running
    CORBA Naming Service with the "-ORBInitRef NameService=..." command-
    line option.  Because the test does not clean up after itself (it
    leaves some bindings in the Naming Service when it exits), the
    Naming Service must be restarted before the test can run again.
    Some tests will fail if the test is re-run without restarting the
    Naming Service.
