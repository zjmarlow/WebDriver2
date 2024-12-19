use v6;

use WebDriver2::Command::Param::Factory;

unit class WebDriver2::Command::Param::Factory::Edge is WebDriver2::Command::Param::Factory;

method session {
	{
		#		desiredCapabilities => { 'unhandledPromptBehavior' => 'ignore' },
		#		requiredCapabilities => {}
		capabilities => { edgeOptions => { :!w3c } }
	}
}
