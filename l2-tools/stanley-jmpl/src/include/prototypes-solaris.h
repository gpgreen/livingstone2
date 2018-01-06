/* $Id: prototypes-solaris.h,v 1.1.1.1 2006/04/18 20:17:28 taylor Exp $ */

/* prototypes needed by Stanley under Sun Solaris 5.5
   */

/* gui/stanley/c/ */
extern int          system(const char *);
extern long         random(void);
extern int          srandom(unsigned int);
extern double       hypot (double, double);
extern char *       strdup(const char *);

/* gui/stanley/ipc/  */
extern int          fileno(FILE *);
extern void         usleep(unsigned int);

