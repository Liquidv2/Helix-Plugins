# Scoreboard Flags
Adds a "Edit Flag" button to the scoreboard context menu  
with a 'Save Button' config option so that not every change gets directly sent to the server.  

![Screenshot](https://user-images.githubusercontent.com/43032513/118579722-e62ed500-b78e-11eb-8d9f-4a20f175b6e5.png)

# Homes
Adds most things that come to mind, like:<br>
  <ul>
    <li>/sethome  -Sets a home at the current position.</li> 
    <li>/delhome  -Deletes specified home [all will delete ALL homes].</li>
    <li>/home     -Teleports you to a specified home.</li>
    <li>/homelist -Lists all your homes in chat.</li>
  </ul>
If no args are given will default to default value ( normally: 'home' )<br>
<br>
<br>
Configs:<br>
<br>
    <ul>
      <li>AdminOnly</li>
      <li>HomeLimit -How many homes people can create [0 for infinite]</li> 
      <li>TeleportTime -How long it takes to TP</li>
      <li>DamageCheck -Cancel TP when getting damage</li>
      <li>MovementCheck -Cancel TP when moving</li>
      <li>WeaponCheck -Cancel TP when switching to another weapon</li>
    </ul>
    <br>
Custom Privilege: 'Helix - Homes'
