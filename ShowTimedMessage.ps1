param([string]$message, [int]$duration)

Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Message'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$label = New-Object System.Windows.Forms.Label
$label.Text = $message
$label.Dock = 'Fill'
$label.TextAlign = 'MiddleCenter'
$form.Controls.Add($label)

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $duration * 1500  # Convert seconds to milliseconds
$timer.Add_Tick({
    $form.Close()
})
$timer.Start()

$form.ShowDialog()