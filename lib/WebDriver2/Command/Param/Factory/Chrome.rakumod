use v6;

use WebDriver2::Command::Param::Factory;

unit class WebDriver2::Command::Param::Factory::Chrome is WebDriver2::Command::Param::Factory;

method session {
	{
#		desiredCapabilities => {
#			alwaysMatch => {
#				unhandledPromptBehavior => 'dismiss'
#			},
#			unhandledPromptBehavior => 'dismiss'
#		},
		#		requiredCapabilities => {}
		capabilities => {
			alwaysMatch => {
				unhandledPromptBehavior => {
					alert =>  'ignore',
					beforeUnload => 'ignore',
					confirm => 'ignore',
					default => 'ignore',
					prompt => 'ignore',
					defaultPrompt => 'ignore',
					:!notify
				}
#				pageLoadStrategy => 1
			}
#			chromeOptions => {
##				:!w3c,
#				unhandledPromptBehavior => 'dismiss'
#			},
#			unhandledPromptBehavior => 'dismiss'
		}
#		chromeOptions => {
#			#				:!w3c,
#			unhandledPromptBehavior => 'dismiss'
#		},
#		unhandledPromptBehavior => 'dismiss'
	}
}
