#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  int i;

  for(i = 1; i < argc; i++)
    printf(1, "CSE3320 proj0 printing in user space: %s%s", argv[i], i+1 < argc ? " " : "\n");
  exit();
}
