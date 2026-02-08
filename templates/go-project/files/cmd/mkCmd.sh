
mkdir -p $1

cat <<EOF > $1/$1.go
package $1

import (
	"flag"
	"fmt"
	"os"

	"grit/db"
	"grit/log"
)

var logger = log.NewLogger("$1")

// Command flags, package-level variables
var (
	// ...
)

// RegisterFlags sets up the flags for this command
func RegisterFlags(fs *flag.FlagSet) {
	
}

// Execute runs the command
func Execute() {
  // ...
	logger.Printf("Command $1 completed\n")
}

EOF

echo "Created new $1 command"