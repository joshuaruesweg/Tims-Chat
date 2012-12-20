<?php
namespace wcf\system\chat\permission;
use \wcf\system\acl\ACLHandler;
use \wcf\system\cache\CacheHandler;
use \wcf\system\package\PackageDependencyHandler;
use \wcf\system\WCF;

/**
 * Handles chat-permissions.
 *
 * @author 	Tim Düsterhus, Marcel Werk
 * @copyright	2010-2012 WoltLab GmbH
 * @license	GNU Lesser General Public License <http://opensource.org/licenses/lgpl-license.php>
 * @package	be.bastelstu.wcf.chat
 * @subpackage	system.chat.permissions
 */
class ChatPermissionHandler {
	/**
	 * permissions set for the active user
	 * @var array<boolean>
	 */
	protected $chatPermissions = array();
	
	/**
	 * given user decorated in a user profile
	 * @var \wcf\data\user\UserProfile
	 */
	protected $user = null;
	
	public function __construct(\wcf\data\user\User $user = null) {
		if ($user === null) $user = WCF::getUser();
		$this->user = new \wcf\data\user\UserProfile($user);
		
		$packageID = \wcf\util\ChatUtil::getPackageID();
		$ush = \wcf\system\user\storage\UserStorageHandler::getInstance();
		
		// get groups permissions
		$groups = implode(',', $user->getGroupIDs());
		$groupsFileName = \wcf\util\StringUtil::getHash(implode('-', $user->getGroupIDs()));
		CacheHandler::getInstance()->addResource('chatPermission-'.$groups, WCF_DIR.'cache/cache.chatPermission-'.$groupsFileName.'.php', '\wcf\system\cache\builder\ChatPermissionCacheBuilder');
		$this->chatPermissions = CacheHandler::getInstance()->get('chatPermission-'.$groups);
		
		// get user permissions
		if ($user->userID) {
			// get data from storage
			$ush->loadStorage(array($user->userID), $packageID);
			
			// get ids
			$data = $ush->getStorage(array($user->userID), 'chatUserPermissions', $packageID);
			
			// cache does not exist or is outdated
			if ($data[$user->userID] === null) {
				$userPermissions = array();
				
				$conditionBuilder = new \wcf\system\database\util\PreparedStatementConditionBuilder();
				$conditionBuilder->add('acl_option.packageID IN (?)', array(PackageDependencyHandler::getInstance()->getDependencies()));
				$conditionBuilder->add('acl_option.objectTypeID = ?', array(ACLHandler::getInstance()->getObjectTypeID('be.bastelstu.wcf.chat.room')));
				$conditionBuilder->add('option_to_user.optionID = acl_option.optionID');
				$conditionBuilder->add('option_to_user.userID = ?', array($user->userID));
				$sql = "SELECT		option_to_user.objectID AS roomID, option_to_user.optionValue,
							acl_option.optionName AS permission
					FROM		wcf".WCF_N."_acl_option acl_option,
							wcf".WCF_N."_acl_option_to_user option_to_user
							".$conditionBuilder;
				$stmt = WCF::getDB()->prepareStatement($sql);
				$stmt->execute($conditionBuilder->getParameters());
				while ($row = $stmt->fetchArray()) {
					$userPermissions[$row['roomID']][$row['permission']] = $row['optionValue'];
				}
				
				// update cache
				$ush->update($user->userID, 'chatUserPermissions', serialize($userPermissions), $packageID);
			}
			else {
				$userPermissions = unserialize($data[$user->userID]);
			}
			
			foreach ($userPermissions as $roomID => $permissions) {
				foreach ($permissions as $name => $value) {
					$this->chatPermissions[$roomID][$name] = $value;
				}
			}
		}
	}
	
	/**
	 * Fetches the given permission for the given room
	 *
	 * @param	\wcf\data\chat\room\ChatRoom	$room
	 * @param	string				$permission
	 * @return	boolean
	 */
	public function getPermission(\wcf\data\chat\room\ChatRoom $room, $permission) {
		if (!isset($this->chatPermissions[$room->roomID][$permission])) {
			$permission = str_replace(array('user.', 'mod.'), array('user.chat.', 'mod.chat.'), $permission);
			
			return $this->user->getPermission($permission);
		}
		return (boolean) $this->chatPermissions[$room->roomID][$permission];
	}
	
	/**
	 * Clears the cache.
	 */
	public static function clearCache() {
		$packageID = \wcf\util\ChatUtil::getPackageID();
		$ush = \wcf\system\user\storage\UserStorageHandler::getInstance();
		
		$ush->resetAll('chatUserPermissions', $packageID);
		\wcf\system\cache\CacheHandler::getInstance()->clear(WCF_DIR.'cache', 'cache.chatPermission-[a-f0-9]{40}.php');
	}
}
