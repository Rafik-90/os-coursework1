import java.util.PriorityQueue;
import java.util.Properties;
import java.util.Comparator;

/**
 * Shortest Job First Scheduler
 * 
 * @version 2017
 */
public class SJFScheduler extends AbstractScheduler {

  private PriorityQueue<Process> readyQueue;
  private double alpha;
  private int initialBurstEstimate;

  public SJFScheduler() {
    // Comparator to sort processes by their estimated next CPU burst
    Comparator<Process> burstTimeComparator = (p1, p2) -> Double.compare(estimateNextBurst(p1), estimateNextBurst(p2));
    readyQueue = new PriorityQueue<>(burstTimeComparator);
  }

  @Override
  public void initialize(Properties parameters) {
    // Read the initial burst estimate and alpha from the properties
    initialBurstEstimate = Integer.parseInt(parameters.getProperty("initialBurstEstimate", "5")); // Default to 5 if not specified
    alpha = Double.parseDouble(parameters.getProperty("alphaBurstEstimate", "0.5")); // Default to 0.5 if not specified
  }





  @Override
  public void ready(Process process, boolean usedFullTimeQuantum) {
    // Add a process to the ready queue. The time quantum is not relevant here as SJF is non-preemptive.
    readyQueue.add(process);
  }



  /**
   * Removes the next process to be run from the ready queue 
   * and returns it. 
   * Returns null if there is no process to run.
   */
  @Override
  public Process schedule() {
    // Return and remove the process with the shortest estimated next burst from the ready queue
    return readyQueue.poll();
  }


  private double estimateNextBurst(Process process) {
    // Use exponential averaging to estimate the next burst duration
    // If a process has no recent burst, use the initial estimate
    if (process.getRecentBurst() == -1) {
      return initialBurstEstimate;
    }
    // Tau(n+1) = alpha * T(n) + (1 - alpha) * Tau(n)
    // Where Tau(n) is the previous estimate, T(n) is the actual burst time, and alpha is the history parameter
    return alpha * process.getRecentBurst() + (1 - alpha) * initialBurstEstimate; // Simplified, as we don't track previous estimates
  }

  @Override
  public int getTimeQuantum() {
    // SJF does not use time quanta, so return the default -1 to indicate this
    return -1;
  }

  @Override
  public boolean isPreemptive() {
    // SJFScheduler is non-preemptive
    return false;
  }

}
