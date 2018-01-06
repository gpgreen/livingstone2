/* $Id: prototypes.h,v 1.1.1.1 2006/04/18 20:17:28 taylor Exp $ */

/* prototypes needed by Stanley under SunOS 4.1.4
   stolen from Sun Solaris 5.4 
   */

/* gui/stanley/c/ */
extern int          fprintf(FILE *, const char *, ...);
extern int          printf(const char *, ...);
extern int          fclose(FILE *);
extern int          system(const char *);
extern int          sscanf(const char *, const char *, ...);
extern long         random(void);
extern int          srandom(unsigned int);
extern unsigned int time(time_t *);

/* gui/stanley/ipc/ */
extern int          _filbuf(FILE *);
extern int          _flsbuf(int, FILE *);
extern int          fflush(FILE *);
extern void         usleep(unsigned int);

