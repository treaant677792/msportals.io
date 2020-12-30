pushd $PSScriptRoot
Describe 'Check Portal Files' {
    
    $PortalFiles = Get-ChildItem -Path . -Filter *.json | Where-Object { $_.Name -notmatch ".*schema.json$" } 
    
    
    $PortalFilesParams = $PortalFiles | Foreach-Object {
        @{
            PortalFileName = $_.Name
            FileObj        = $_
        }
    }

    Context "Check <PortalFileName>" {
        $currentFile = @{
            PortalFileName = $_.PortalFileName
            FileObj        = $_
        }

        It '<PortalFileName> should be able to convert as valid JSON' -TestCases @($_) {
            param ($PortalFileName, $FileObj)

            { Get-Content -Path ($FileObj.FullName) -raw | ConvertFrom-Json } | Should -Not -Throw
        } 
        
        It '<PortalFileName> should contain 1 or more Portal Groups' -TestCases @($_) {
            param ($PortalFileName, $FileObj)

            $PortalGroups = (Get-Content -Path ($FileObj.FullName) -raw | ConvertFrom-Json )
            $PortalGroups.groupName.Count  | Should -BeGreaterOrEqual 1

            # $PortalGroupsIterate = $PortalGroups | Select-Object groupName, portals, @{N = "PortalFileName"; E = { $PortalFileName } }
            #
            # Context "<PortalFileName> - PortalGroup <PortalGroupName>" {
            #     $CurrentPortalGroup = @{
            #         PortalGroupName = $_.groupName
            #         PortalFileName  = $_.PortalFileName
            #         PortalGroup     = $_
            #     }
            #
            #     It 'Group <PortalGroupName> should contain 1 or more Portals ' -TestCases @($CurrentPortalGroup) {
            #         param ($PortalGroupName, $PortalFileName, $PortalGroup)
            #      
            #         $portals = $_.portals
            #         $portals.Count  | Should -BeGreaterOrEqual 1
            #
            #         # $portals | Add-Member -NotePropertyName "PortalFileName" -NotePropertyValue $PortalFileName
            #         # $portals | Add-Member -NotePropertyName "PortalFileName" -NotePropertyValue $PortalFileName
            #
            #         #     Context "Foreach Portal in " {
            #         #         $CurrentPortal = @{
            #         #             PortalName = $_
            #         #             Portal     = $_.FileObj.FullName
            #         #         } 
            #
            #         #         It '<Name> should be able to convert as valid JSON' -TestCases @($currentFile) {
            #         #             param ($Name, $FileObj)
            #
            #         #             { Get-Content -Path $FileObj -raw | ConvertFrom-Json } | Should -Not -Throw
            #         #         }
            #
            #         #         It 'Portal can only have one note attribute' -TestCases @($currentFile) {
            #         #             param ($Name, $FileObj)
            #
            #         #             { Get-Content -Path $FileObj -raw | ConvertFrom-Json } | Should -Not -Throw
            #         #         }
            #         #     }
            #     }
            # } -Foreach $PortalGroupsIterate
        }

    } -Foreach $PortalFilesParams
}
