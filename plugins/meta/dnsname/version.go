package main

import "fmt"

// overwritten at build time
var gitCommit = "unknown"

const dnsnameVersion = "1.3.0"

func getVersion() string {
	return fmt.Sprintf(`CNI dnsname plugin
version: %s
commit: %s`, dnsnameVersion, gitCommit)
}
