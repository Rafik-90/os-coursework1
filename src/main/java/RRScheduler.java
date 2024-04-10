import java.util.LinkedList;
import java.util.Properties;
import java.util.Queue;
/**
 * Round Robin Scheduler
 * 
 * @version 2017
 */
public class RRScheduler extends AbstractScheduler {

  private Queue<Process> readyQueue; // Queue to hold the ready processes
  private int timeQuantum; // Time Quantum for the Round Robin scheduling

  public RRScheduler() {
    readyQueue = new LinkedList<>();
  }
  @Override
  public void initialize(Properties parameters) {
    // Reading timeQuantum from the provided parameters
    this.timeQuantum = Integer.parseInt(parameters.getProperty("timeQuantum"));
  }



  /**
   * Adds a process to the ready queue.
   * usedFullTimeQuantum is true if process is being moved to ready
   * after having fully used its time quantum.
   */

  public void ready(Process process, boolean usedFullTimeQuantum) {
    // Add the process to the ready queue
    if (usedFullTimeQuantum) {
      readyQueue.remove(process);
    }
    readyQueue.add(process);
  }


  /**
   * Removes the next process to be run from the ready queue 
   * and returns it. 
   * Returns null if there is no process to run.
   */

  public Process schedule() {
    // Fetch the next process from the ready queue
    return readyQueue.poll();
  }

  @Override
  public int getTimeQuantum() {
    // Returns the specified time quantum for Round Robin scheduling
    return timeQuantum;
  }

  @Override
  public boolean isPreemptive() {
    // Round Robin is considered non-preemptive in this context
    return false;
  }


}


