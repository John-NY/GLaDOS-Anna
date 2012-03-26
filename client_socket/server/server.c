/* A simple server in the internet domain using TCP
   The port number is passed as an argument 
   This version runs forever, forking off a separate 
   process for each connection
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

#include <signal.h>

void dostuff(int); /* function prototype */
int safe_exe(char*); /* function prototype */

void error(const char *msg)
{
    perror(msg);
    exit(1);
}

/* http://www.advancedlinuxprogramming.com/alp-folder/alp-ch03-processes.pdf */
sig_atomic_t child_exit_status;
/* Clean up after your children */
void clean_up_child_process (int signal_number)
{
     int status;
     wait (&status);
     /* Store its exit status in a global variable. */
     child_exit_status = status;
}

int main(int argc, char *argv[])
{
     int sockfd, newsockfd, portno, pid;
     socklen_t clilen;
     struct sockaddr_in serv_addr, cli_addr;

     /* Handle SIGCHLD by calling clean_up_child_process. */
     struct sigaction sigchld_action;
     memset (&sigchld_action, 0, sizeof (sigchld_action));
     sigchld_action.sa_handler = &clean_up_child_process;
     /* sigaction (SIGCHLD, &sigchld_action, NULL); */
     /* zombies ain't so bad after all... better than threads */

     if (argc < 2) {
         fprintf(stderr,"ERROR, no port provided\n");
         exit(1);
     }
     sockfd = socket(AF_INET, SOCK_STREAM, 0);
     if (sockfd < 0) 
        error("ERROR opening socket");
     bzero((char *) &serv_addr, sizeof(serv_addr));
     portno = atoi(argv[1]);
     serv_addr.sin_family = AF_INET;
     serv_addr.sin_addr.s_addr = INADDR_ANY;
     serv_addr.sin_port = htons(portno);
     if (bind(sockfd, (struct sockaddr *) &serv_addr,
              sizeof(serv_addr)) < 0) 
              error("ERROR on binding");
     listen(sockfd,5);
     clilen = sizeof(cli_addr);
     while (1) {
         newsockfd = accept(sockfd, 
               (struct sockaddr *) &cli_addr, &clilen);
         if (newsockfd < 0) 
             error("ERROR on accept");
         pid = fork();
         if (pid < 0)
             error("ERROR on fork");
         if (pid == 0)  {
             close(sockfd);
             dostuff(newsockfd);
             exit(0);
         }
         else {
             close(newsockfd); /* continue */
	}
     } /* end of while */
     close(sockfd);
     return 0; /* we never get here */
}

/******** DOSTUFF() *********************
 There is a separate instance of this function 
 for each connection.  It handles all communication
 once a connnection has been established.
 *****************************************/
void dostuff (int sock)
{
   int n;
   char buffer[256];
   char* command;
   command = (char*)malloc(1024);
   for (n = 0; n < 1024; n++)
      command[n] = 0x00;
      
   bzero(buffer,256);
   n = read(sock,buffer,255);
   if (n < 0) error("ERROR reading from socket");
   printf("Here is the message: %s\n",buffer);
   sprintf(command,"\"%s\"",buffer);
   safe_exe(command);
   n = write(sock,"I got your message",18);
   if (n < 0) error("ERROR writing to socket");
}

int safe_exe (char* command)
{ /* sanitize inputs */
    char *input = NULL;
   printf("%s\n",command);
     
    /* input gets initialized by user */
     
    pid_t pid;
    int status;
    pid_t ret;
    char *const args[3] = {"GLaDOS",(char*)malloc(1024),NULL};
    char **env;
    extern char **environ;
     
    /*... Sanitize arguments ... */
    sprintf(args[1],"%s",command);
     
    pid = fork();
    if (pid == -1) {
        perror("fork error");
    }
    else if (pid != 0) {
        while ((ret = waitpid(pid, &status, 0)) == -1) {
            if (errno != EINTR) {
                perror("Error waiting for child process");
                break;
            }
        }
        if ((ret != -1) &&
                (!WIFEXITED(status) || !WEXITSTATUS(status)) ) {
            /* Report unexpected child status */
        }
    } else {
     
        /*... Initialize env as a sanitized copy of environ ...*/
     
        if (execve("/usr/bin/GLaDOS", args, env) == -1) {
            perror("Error executing GLaDOS");
            _exit(127);
        }
    }
}

/* 
Calling exec() does NOT create a new process. calling fork creates the new process. what i was trying to say was: if u have a thread call an exec() function, THE ENTIRE process that the thread was a part of will cease to run and be replaced by the process that is being exec'd. so if one thread is off serving a client, and another thread in that process calls execve(), the thread servering the client will be killed when the other thread calls execve(). what the exec family of functions does is replace the entire address space of the current process. if u dont want to have any 'zombied' children, then install a signal handler in your parent process that will catch SIGCHLD and cleanup any children that die. if one the other hand your main program will be exiting before the children, what you can do is instead install an atexit() handler in the parent process that will send a SIGKILL or SIGQUIT to the ENTIRE PROCESS GROUP of the parent. then, all the child process's will be sent a SIGKILL signal when the parent exits, and they will exit as well.
*/
