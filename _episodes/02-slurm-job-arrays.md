
---
title: "Slurm Job Array"
teaching: 15
exercises: 5
questions:
- "What is a Slurm job array"
keypoints:
- "Dependency chains allow for better scheduling."
---
The best way to submit many jobs in a responsible and easy to handle way is to use Slurm Job arrays.



> ## Why this way? 
> What are the advantages of using of using Slurm job dependencies over submitting the next stage on the completion of the first?
> > ## Solution
> > * Scheduling: Using dependencies allows your later stages to submitted into the queue much earlier, reducing wait time between stages.
> > e.g. `stage1.sl` is expected to run for 10:00:00, if `stage2.sl` is submitted at the same time, dependent on `stage1.sl`, the sceduler will have 10 hours more to find and reserve the appropriate resources needed than if `stage2.sl` was submitted at the end of `stage1.sl`.
> {: .solution}
{: .challenge}

## scatter-gather workflow


{% include links.md %}
