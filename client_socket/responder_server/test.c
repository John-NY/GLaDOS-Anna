/* A simple server in the internet domain using TCP
   The port number is passed as an argument 
   This version runs forever, forking off a separate 
   process for each connection

   This responder_server version will read the system
   health and status to the client.
*/
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>

#include <errno.h>
#include <sys/wait.h>

#include <sys/types.h>
#include <sys/stat.h>

#include <signal.h>

int main(int argc, char *argv[])
{
   char s_health_and_status_filename[1024];
   sprintf(s_health_and_status_filename,"test.txt");
   struct stat sb;
   FILE* p_health_and_status;
   size_t n_read;
   size_t sz_block = 1024;
   char *c_buffer;
   c_buffer = (char*) malloc(sizeof(char)*sz_block+2);

   /* if file open or status (I love C) */
   if ( ((p_health_and_status = fopen(s_health_and_status_filename,"r")) == NULL) || fstat(fileno(p_health_and_status), &sb) )
   {
   } else {
      while (!feof(p_health_and_status)) 
      {
         bzero(c_buffer,sz_block);
         n_read = fread(c_buffer,sizeof(char),sz_block,p_health_and_status);
         printf("%s",c_buffer);
/*         (void)fflush(stdout); */
      }
      fclose(p_health_and_status);
   }
   free(c_buffer);
}

