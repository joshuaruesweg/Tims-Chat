<?php
namespace chat\system\command;

/**
 * Thrown when a user is not found.
 * 
 * @author 	Tim Düsterhus
 * @copyright	2010-2014 Tim Düsterhus
 * @license	Creative Commons Attribution-NonCommercial-ShareAlike <http://creativecommons.org/licenses/by-nc-sa/3.0/legalcode>
 * @package	be.bastelstu.chat
 * @subpackage	system.chat.command
 */
class UserNotFoundException extends \Exception {
	/**
	 * given username
	 * @var string
	 */
	private $username = '';
	
	public function __construct($username) {
		$this->username = $username;
	}
	
	/**
	 * Returns the given username
	 * 
	 * @return string
	 */
	public function getUsername() {
		return $this->username;
	}
}
