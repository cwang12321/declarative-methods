# map task name to duration, and track list of precedence pairs
tasks = {}
precedences = []

# read data file
with open('rcps.data') as f:
    lines = f.readlines()

section = None
for line in lines:
    line = line.strip()
    if not line:
        continue
    if line.startswith('section1'):
        section = 1
        continue
    if line.startswith('section2'):
        section = 2
        continue
    if line.startswith('section3'):
        break
    
    args = line.split()
    if section == 1:
        name = args[0]
        h, m = args[1].split(':')
        duration = int(h) * 60 + int(m)
        tasks[name] = duration

    elif section == 2:
         predecessor = args[0]
         successor = args[1]
         precedences.append((predecessor, successor))

# convert variable names 
def start_var(name):
    return 'S_' + name.replace('.', '_')

def finish_var(name):
    return 'F_' + name.replace('.', '_')

# write file
upper_bound = sum(tasks.values())
task_names = list(tasks.keys())

with open('problem1.ecl', 'w') as f:
    # header
    f.write(':- lib(ic).\n')
    f.write(':- lib(branch_and_bound).\n')
    f.write(':- lib(lists).\n\n')

    f.write('schedule(EndTime) :-\n\n')

    # declare all start/finish variables
    # used chunks for better readability
    f.write('   % variable declarations\n')
    for i in range(0, len(task_names), 10):
        chunk = task_names[i:i+10]
        s_vars = ', '.join(start_var(n) for n in chunk)
        f_vars = ', '.join(finish_var(n) for n in chunk)
        f.write(f'    [{s_vars}] :: 0..{upper_bound},\n')
        f.write(f'    [{f_vars}] :: 0..{upper_bound},\n')

    # duration constraints
    f.write('\n    % duration constraints\n')
    for name in task_names:
        s = start_var(name)
        fv = finish_var(name)
        d = tasks[name]
        f.write(f'    {fv} - {s} #= {d},\n')
    
    # precedence constraints
    f.write('\n     % precedence constraints\n')
    for pred, succ in precedences:
        f.write(f'    {start_var(succ)} #>= {finish_var(pred)},\n')

    # end time must be >= every finish time
    f.write('\n     % end time has to be finish time of the final task\n')
    f.write(f'    EndTime :: 0..{upper_bound},\n')
    for name in task_names:
        f.write(f'    EndTime #>= {finish_var(name)},\n')
    
    # minimize
    all_s = ', '.join(start_var(n) for n in task_names)
    all_f = ', '.join(finish_var(n) for n in task_names)
    f.write('\n     % minimize end time')
    f.write(f'\n     flatten([{all_s},{all_f},EndTime], AllVars),\n')
    f.write('   minimize(labeling(AllVars), EndTime),\n\n')

    # print 
    f.write('   % print results\n')
    f.write('   printf("Found a solution with cost %d\\n", [EndTime]), \n')
    for name in task_names:
        s = start_var(name)
        fv = finish_var(name)
        f.write(f'  printf("{name} %d - %d\\n", [{s}, {fv}]),\n')
    
    f.write('   printf("\\nDone\\n", []).\n\n')

print('Done!')