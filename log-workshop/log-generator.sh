#!/bin/bash
# =============================================================================
# Workshop Log Generator
# Generates realistic logs for Datadog workshop demonstrations
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# -----------------------------------------------------------------------------
# Color Output
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Sample Data Arrays
# -----------------------------------------------------------------------------
USERS=("alice" "bob" "charlie" "diana" "eve" "frank" "grace" "henry" "iris" "jack")
USER_IDS=("usr_1001" "usr_1002" "usr_1003" "usr_1004" "usr_1005" "usr_1006" "usr_1007" "usr_1008" "usr_1009" "usr_1010")
ENDPOINTS=("/api/v1/users" "/api/v1/orders" "/api/v1/products" "/api/v1/payments" "/api/v1/inventory" "/api/v1/search" "/api/v1/cart" "/api/v1/checkout" "/api/v2/users" "/api/v2/orders")
HTTP_METHODS=("GET" "POST" "PUT" "DELETE" "PATCH")
STATUS_CODES_SUCCESS=(200 201 204)
STATUS_CODES_ERROR=(400 401 403 404 500 502 503)
PAYMENT_METHODS=("credit_card" "debit_card" "paypal" "apple_pay" "google_pay" "bank_transfer")
CURRENCIES=("USD" "EUR" "GBP" "JPY" "CAD")
TRANSACTION_IDS=()
REQUEST_IDS=()
TRACE_IDS=()

# Java Exception Classes
JAVA_EXCEPTIONS=("NullPointerException" "IllegalArgumentException" "RuntimeException" "SQLException" "IOException" "TimeoutException" "ConnectionException" "AuthenticationException" "ValidationException" "OutOfMemoryError")
JAVA_PACKAGES=("com.mycompany.api" "com.mycompany.service" "com.mycompany.repository" "com.mycompany.controller" "com.mycompany.util" "org.springframework.web" "org.hibernate" "java.lang" "java.util" "java.io")
JAVA_CLASSES=("UserController" "PaymentProcessor" "OrderService" "DatabaseConnection" "AuthenticationFilter" "RequestHandler" "CacheManager" "MessageQueue" "DataValidator" "SessionManager")
JAVA_METHODS=("processRequest" "validateInput" "executeQuery" "handlePayment" "authenticateUser" "getConnection" "sendMessage" "parseData" "updateCache" "closeSession")

# Log Levels
LOG_LEVELS_NORMAL=("INFO" "DEBUG" "TRACE")
LOG_LEVELS_ERROR=("ERROR" "WARN" "FATAL")

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

random_element() {
    local arr=("$@")
    echo "${arr[$RANDOM % ${#arr[@]}]}"
}

random_number() {
    local min=$1
    local max=$2
    echo $((RANDOM % (max - min + 1) + min))
}

generate_uuid() {
    if command -v uuidgen &> /dev/null; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    else
        cat /dev/urandom | LC_ALL=C tr -dc 'a-f0-9' | fold -w 32 | head -n 1 | sed 's/\(.\{8\}\)\(.\{4\}\)\(.\{4\}\)\(.\{4\}\)/\1-\2-\3-\4-/'
    fi
}

generate_trace_id() {
    cat /dev/urandom | LC_ALL=C tr -dc 'a-f0-9' | fold -w 16 | head -n 1
}

generate_span_id() {
    cat /dev/urandom | LC_ALL=C tr -dc 'a-f0-9' | fold -w 8 | head -n 1
}

get_timestamp_iso() {
    date -u +"%Y-%m-%dT%H:%M:%S.000Z"
}

get_timestamp_unix() {
    date +%s
}

# INTENTIONAL ISSUE: Various timestamp formats that need normalization
get_timestamp_broken() {
    local format_type=$((RANDOM % 5))
    case $format_type in
        0) date +"%Y/%m/%d %H:%M:%S" ;;           # Slashes instead of dashes
        1) date +"%d-%m-%Y %H:%M:%S" ;;           # European format
        2) date +"%b %d %H:%M:%S %Y" ;;           # Syslog format
        3) date +"%Y-%m-%d %I:%M:%S %p" ;;        # 12-hour format
        4) date +%s ;;                             # Unix timestamp
    esac
}

should_happen() {
    local probability=$1
    [ $((RANDOM % 100)) -lt $probability ]
}

# -----------------------------------------------------------------------------
# Log Generators
# -----------------------------------------------------------------------------

# API Gateway - JSON Format (Modern Microservice)
generate_api_gateway_log() {
    local timestamp
    local level
    local method=$(random_element "${HTTP_METHODS[@]}")
    local endpoint=$(random_element "${ENDPOINTS[@]}")
    local user=$(random_element "${USERS[@]}")
    local user_id=$(random_element "${USER_IDS[@]}")
    local request_id=$(generate_uuid)
    local trace_id=$(generate_trace_id)
    local duration=$(random_number 5 2000)
    local status_code
    local is_error=false
    
    # Determine if this is an error log
    if should_happen $ERROR_RATE; then
        is_error=true
        level=$(random_element "${LOG_LEVELS_ERROR[@]}")
        status_code=$(random_element "${STATUS_CODES_ERROR[@]}")
    else
        level=$(random_element "${LOG_LEVELS_NORMAL[@]}")
        status_code=$(random_element "${STATUS_CODES_SUCCESS[@]}")
    fi
    
    # INTENTIONAL ISSUE: Inconsistent timestamp formats
    if [[ "$ENABLE_BROKEN_TIMESTAMPS" == "true" ]] && should_happen 30; then
        timestamp=$(get_timestamp_broken)
    else
        timestamp=$(get_timestamp_iso)
    fi
    
    # INTENTIONAL ISSUE: Sometimes missing fields
    if [[ "$ENABLE_MISSING_FIELDS" == "true" ]] && should_happen 15; then
        # Missing user_id field
        echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"service\":\"$API_GATEWAY_SERVICE\",\"method\":\"$method\",\"endpoint\":\"$endpoint\",\"status\":$status_code,\"duration_ms\":$duration,\"request_id\":\"$request_id\",\"trace_id\":\"$trace_id\",\"message\":\"Request processed\"}"
    elif [[ "$ENABLE_MISSING_FIELDS" == "true" ]] && should_happen 10; then
        # Missing trace_id field
        echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"service\":\"$API_GATEWAY_SERVICE\",\"user\":\"$user\",\"user_id\":\"$user_id\",\"method\":\"$method\",\"endpoint\":\"$endpoint\",\"status\":$status_code,\"duration_ms\":$duration,\"request_id\":\"$request_id\",\"message\":\"Request processed\"}"
    else
        echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"service\":\"$API_GATEWAY_SERVICE\",\"user\":\"$user\",\"user_id\":\"$user_id\",\"method\":\"$method\",\"endpoint\":\"$endpoint\",\"status\":$status_code,\"duration_ms\":$duration,\"request_id\":\"$request_id\",\"trace_id\":\"$trace_id\",\"message\":\"Request processed\"}"
    fi
}

# Payment Service - JSON Format with nested objects
generate_payment_service_log() {
    local timestamp
    local level
    local transaction_id="txn_$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)"
    local user_id=$(random_element "${USER_IDS[@]}")
    local amount=$(random_number 10 5000)
    local currency=$(random_element "${CURRENCIES[@]}")
    local payment_method=$(random_element "${PAYMENT_METHODS[@]}")
    local trace_id=$(generate_trace_id)
    local is_error=false
    
    if should_happen $ERROR_RATE; then
        is_error=true
        level=$(random_element "${LOG_LEVELS_ERROR[@]}")
    else
        level=$(random_element "${LOG_LEVELS_NORMAL[@]}")
    fi
    
    if [[ "$ENABLE_BROKEN_TIMESTAMPS" == "true" ]] && should_happen 25; then
        timestamp=$(get_timestamp_broken)
    else
        timestamp=$(get_timestamp_iso)
    fi
    
    if [[ "$is_error" == "true" ]]; then
        local error_messages=("Payment declined" "Insufficient funds" "Card expired" "Gateway timeout" "Fraud detection triggered" "Invalid card number")
        local error_msg=$(random_element "${error_messages[@]}")
        
        # INTENTIONAL ISSUE: Error logs sometimes have different structure
        if [[ "$ENABLE_MIXED_FORMATS" == "true" ]] && should_happen 20; then
            # Plain text error mixed in JSON file
            echo "[$timestamp] $level - Payment failed for transaction $transaction_id: $error_msg"
        else
            echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"service\":\"$PAYMENT_SERVICE_SERVICE\",\"transaction\":{\"id\":\"$transaction_id\",\"amount\":$amount,\"currency\":\"$currency\",\"method\":\"$payment_method\"},\"user_id\":\"$user_id\",\"trace_id\":\"$trace_id\",\"status\":\"FAILED\",\"error\":\"$error_msg\"}"
        fi
    else
        local statuses=("PENDING" "PROCESSING" "COMPLETED" "AUTHORIZED")
        local status=$(random_element "${statuses[@]}")
        echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"service\":\"$PAYMENT_SERVICE_SERVICE\",\"transaction\":{\"id\":\"$transaction_id\",\"amount\":$amount,\"currency\":\"$currency\",\"method\":\"$payment_method\"},\"user_id\":\"$user_id\",\"trace_id\":\"$trace_id\",\"status\":\"$status\",\"message\":\"Payment $status\"}"
    fi
}

# User Service - XML Format (for parsing challenges)
generate_user_service_log() {
    local timestamp
    local level
    local user=$(random_element "${USERS[@]}")
    local user_id=$(random_element "${USER_IDS[@]}")
    local action
    local actions=("LOGIN" "LOGOUT" "PROFILE_UPDATE" "PASSWORD_CHANGE" "REGISTRATION" "SESSION_REFRESH" "2FA_VERIFY" "EMAIL_VERIFY")
    action=$(random_element "${actions[@]}")
    local session_id="sess_$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
    local ip_address="192.168.$((RANDOM % 256)).$((RANDOM % 256))"
    local is_error=false
    
    if should_happen $ERROR_RATE; then
        is_error=true
        level=$(random_element "${LOG_LEVELS_ERROR[@]}")
    else
        level=$(random_element "${LOG_LEVELS_NORMAL[@]}")
    fi
    
    if [[ "$ENABLE_BROKEN_TIMESTAMPS" == "true" ]] && should_happen 25; then
        timestamp=$(get_timestamp_broken)
    else
        timestamp=$(get_timestamp_iso)
    fi
    
    if [[ "$is_error" == "true" ]]; then
        local error_msgs=("Authentication failed" "Session expired" "Invalid credentials" "Account locked" "Rate limit exceeded")
        local error_msg=$(random_element "${error_msgs[@]}")
        
        # INTENTIONAL ISSUE: Multiline XML logs
        if [[ "$ENABLE_MULTILINE_ISSUES" == "true" ]]; then
            cat << EOF
<log>
  <timestamp>$timestamp</timestamp>
  <level>$level</level>
  <service>$USER_SERVICE_SERVICE</service>
  <user>
    <name>$user</name>
    <id>$user_id</id>
  </user>
  <action>$action</action>
  <session_id>$session_id</session_id>
  <ip_address>$ip_address</ip_address>
  <status>FAILED</status>
  <error>$error_msg</error>
</log>
EOF
        else
            echo "<log><timestamp>$timestamp</timestamp><level>$level</level><service>$USER_SERVICE_SERVICE</service><user><name>$user</name><id>$user_id</id></user><action>$action</action><session_id>$session_id</session_id><ip_address>$ip_address</ip_address><status>FAILED</status><error>$error_msg</error></log>"
        fi
    else
        if [[ "$ENABLE_MULTILINE_ISSUES" == "true" ]] && should_happen 40; then
            cat << EOF
<log>
  <timestamp>$timestamp</timestamp>
  <level>$level</level>
  <service>$USER_SERVICE_SERVICE</service>
  <user>
    <name>$user</name>
    <id>$user_id</id>
  </user>
  <action>$action</action>
  <session_id>$session_id</session_id>
  <ip_address>$ip_address</ip_address>
  <status>SUCCESS</status>
</log>
EOF
        else
            echo "<log><timestamp>$timestamp</timestamp><level>$level</level><service>$USER_SERVICE_SERVICE</service><user><name>$user</name><id>$user_id</id></user><action>$action</action><session_id>$session_id</session_id><ip_address>$ip_address</ip_address><status>SUCCESS</status></log>"
        fi
    fi
}

# Legacy Monolith - Plain text format with Java stack traces
generate_legacy_monolith_log() {
    local timestamp
    local level
    local thread_id=$((RANDOM % 100 + 1))
    local class=$(random_element "${JAVA_CLASSES[@]}")
    local method=$(random_element "${JAVA_METHODS[@]}")
    local is_error=false
    
    if should_happen $ERROR_RATE; then
        is_error=true
        level=$(random_element "${LOG_LEVELS_ERROR[@]}")
    else
        level=$(random_element "${LOG_LEVELS_NORMAL[@]}")
    fi
    
    # Legacy system uses various timestamp formats
    if [[ "$ENABLE_BROKEN_TIMESTAMPS" == "true" ]]; then
        local format_type=$((RANDOM % 3))
        case $format_type in
            0) timestamp=$(date +"%Y-%m-%d %H:%M:%S,%3N") ;;  # Log4j style
            1) timestamp=$(date +"%d/%b/%Y:%H:%M:%S %z") ;;   # Apache style
            2) timestamp=$(date +"%b %d %H:%M:%S") ;;         # Syslog style
        esac
    else
        timestamp=$(date +"%Y-%m-%d %H:%M:%S,%3N")
    fi
    
    if [[ "$is_error" == "true" ]]; then
        local exception=$(random_element "${JAVA_EXCEPTIONS[@]}")
        local error_messages=("Failed to process request" "Database connection lost" "Null value encountered" "Invalid state detected" "Timeout waiting for response" "Memory allocation failed")
        local error_msg=$(random_element "${error_messages[@]}")
        
        # INTENTIONAL ISSUE: Java stack traces (multiline)
        if [[ "$ENABLE_MULTILINE_ISSUES" == "true" ]] && should_happen $STACK_TRACE_PROBABILITY; then
            local pkg1=$(random_element "${JAVA_PACKAGES[@]}")
            local pkg2=$(random_element "${JAVA_PACKAGES[@]}")
            local pkg3=$(random_element "${JAVA_PACKAGES[@]}")
            local class1=$(random_element "${JAVA_CLASSES[@]}")
            local class2=$(random_element "${JAVA_CLASSES[@]}")
            local class3=$(random_element "${JAVA_CLASSES[@]}")
            local method1=$(random_element "${JAVA_METHODS[@]}")
            local method2=$(random_element "${JAVA_METHODS[@]}")
            local method3=$(random_element "${JAVA_METHODS[@]}")
            local line1=$((RANDOM % 500 + 1))
            local line2=$((RANDOM % 500 + 1))
            local line3=$((RANDOM % 500 + 1))
            local line4=$((RANDOM % 500 + 1))
            local line5=$((RANDOM % 500 + 1))
            
            cat << EOF
$timestamp [$level] [thread-$thread_id] $class.$method - $error_msg
$exception: $error_msg
	at $pkg1.$class1.$method1($class1.java:$line1)
	at $pkg2.$class2.$method2($class2.java:$line2)
	at $pkg3.$class3.$method3($class3.java:$line3)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:$line4)
	at org.springframework.web.servlet.FrameworkServlet.service(FrameworkServlet.java:$line5)
Caused by: java.lang.RuntimeException: Underlying cause
	at $pkg1.util.Helper.doSomething(Helper.java:$((RANDOM % 200 + 1)))
	... 15 more
EOF
        else
            echo "$timestamp [$level] [thread-$thread_id] $class.$method - $error_msg: $exception"
        fi
    else
        local messages=("Processing request" "Query executed successfully" "Cache hit for key" "Session validated" "Transaction committed" "Batch job completed" "Health check passed" "Configuration reloaded")
        local msg=$(random_element "${messages[@]}")
        local extra_info=""
        
        # Add some random context
        if should_happen 50; then
            extra_info=" - duration: $((RANDOM % 1000))ms"
        fi
        
        echo "$timestamp [$level] [thread-$thread_id] $class.$method - $msg$extra_info"
    fi
}

# -----------------------------------------------------------------------------
# Burst Generator
# -----------------------------------------------------------------------------
generate_burst() {
    local service=$1
    local count=${2:-$BURST_SIZE}
    
    echo -e "${YELLOW}[BURST]${NC} Generating $count logs for $service"
    
    for ((i=0; i<count; i++)); do
        case $service in
            "api-gateway")
                generate_api_gateway_log >> "${LOG_DIR}/${API_GATEWAY_LOG}"
                ;;
            "payment-service")
                generate_payment_service_log >> "${LOG_DIR}/${PAYMENT_SERVICE_LOG}"
                ;;
            "user-service")
                generate_user_service_log >> "${LOG_DIR}/${USER_SERVICE_LOG}"
                ;;
            "legacy-monolith")
                generate_legacy_monolith_log >> "${LOG_DIR}/${LEGACY_MONOLITH_LOG}"
                ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Main Loop
# -----------------------------------------------------------------------------
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   Workshop Log Generator Starting     ${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}Configuration:${NC}"
    echo "  Log Directory: $LOG_DIR"
    echo "  API Gateway Rate: $API_GATEWAY_RATE logs/min"
    echo "  Payment Service Rate: $PAYMENT_SERVICE_RATE logs/min"
    echo "  User Service Rate: $USER_SERVICE_RATE logs/min"
    echo "  Legacy Monolith Rate: $LEGACY_MONOLITH_RATE logs/min"
    echo "  Burst Probability: $BURST_PROBABILITY%"
    echo "  Error Rate: $ERROR_RATE%"
    echo ""
    echo -e "${BLUE}Intentional Issues:${NC}"
    echo "  Broken Timestamps: $ENABLE_BROKEN_TIMESTAMPS"
    echo "  Missing Fields: $ENABLE_MISSING_FIELDS"
    echo "  Multiline Issues: $ENABLE_MULTILINE_ISSUES"
    echo "  Mixed Formats: $ENABLE_MIXED_FORMATS"
    echo ""
    
    # Create log directory
    if [ ! -d "$LOG_DIR" ]; then
        echo -e "${YELLOW}Creating log directory: $LOG_DIR${NC}"
        mkdir -p "$LOG_DIR"
        chmod 755 "$LOG_DIR"
    fi
    
    # Create/clear log files
    for logfile in "$API_GATEWAY_LOG" "$PAYMENT_SERVICE_LOG" "$USER_SERVICE_LOG" "$LEGACY_MONOLITH_LOG"; do
        touch "${LOG_DIR}/${logfile}"
        chmod 644 "${LOG_DIR}/${logfile}"
    done
    
    echo -e "${GREEN}Log files created. Starting generation...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    echo ""
    
    # Calculate sleep intervals (converting logs/min to interval in seconds)
    local api_interval=$(echo "scale=2; 60 / $API_GATEWAY_RATE" | bc)
    local payment_interval=$(echo "scale=2; 60 / $PAYMENT_SERVICE_RATE" | bc)
    local user_interval=$(echo "scale=2; 60 / $USER_SERVICE_RATE" | bc)
    local legacy_interval=$(echo "scale=2; 60 / $LEGACY_MONOLITH_RATE" | bc)
    
    # Track last generation time for each service
    local last_api=0
    local last_payment=0
    local last_user=0
    local last_legacy=0
    local iteration=0
    
    while true; do
        local current_time=$(date +%s)
        iteration=$((iteration + 1))
        
        # Generate API Gateway log
        if (( $(echo "$current_time - $last_api >= $api_interval" | bc -l) )); then
            generate_api_gateway_log >> "${LOG_DIR}/${API_GATEWAY_LOG}"
            last_api=$current_time
            echo -e "${BLUE}[api-gateway]${NC} Log generated"
        fi
        
        # Generate Payment Service log
        if (( $(echo "$current_time - $last_payment >= $payment_interval" | bc -l) )); then
            generate_payment_service_log >> "${LOG_DIR}/${PAYMENT_SERVICE_LOG}"
            last_payment=$current_time
            echo -e "${GREEN}[payment-service]${NC} Log generated"
        fi
        
        # Generate User Service log
        if (( $(echo "$current_time - $last_user >= $user_interval" | bc -l) )); then
            generate_user_service_log >> "${LOG_DIR}/${USER_SERVICE_LOG}"
            last_user=$current_time
            echo -e "${YELLOW}[user-service]${NC} Log generated"
        fi
        
        # Generate Legacy Monolith log
        if (( $(echo "$current_time - $last_legacy >= $legacy_interval" | bc -l) )); then
            generate_legacy_monolith_log >> "${LOG_DIR}/${LEGACY_MONOLITH_LOG}"
            last_legacy=$current_time
            echo -e "${RED}[legacy-monolith]${NC} Log generated"
        fi
        
        # Random burst check
        if should_happen $BURST_PROBABILITY; then
            local services=("api-gateway" "payment-service" "user-service" "legacy-monolith")
            local burst_service=$(random_element "${services[@]}")
            generate_burst "$burst_service"
        fi
        
        # Small sleep to prevent CPU spinning
        sleep 0.5
    done
}

# -----------------------------------------------------------------------------
# Command Line Arguments
# -----------------------------------------------------------------------------
show_help() {
    echo "Workshop Log Generator"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -c, --clean         Clean (remove) existing log files before starting"
    echo "  -d, --dir DIR       Set log output directory (default: /var/log/workshop)"
    echo "  -b, --burst         Trigger a manual burst for all services"
    echo "  --no-issues         Disable all intentional issues (clean logs)"
    echo ""
    echo "Environment Variables (can also be set in config.sh):"
    echo "  LOG_DIR                    Log output directory"
    echo "  API_GATEWAY_RATE           Logs per minute for api-gateway"
    echo "  PAYMENT_SERVICE_RATE       Logs per minute for payment-service"
    echo "  USER_SERVICE_RATE          Logs per minute for user-service"
    echo "  LEGACY_MONOLITH_RATE       Logs per minute for legacy-monolith"
    echo "  BURST_PROBABILITY          Chance of random burst (1-100)"
    echo "  ERROR_RATE                 Percentage of error logs (1-100)"
    echo ""
    echo "Examples:"
    echo "  $0                         Start with default settings"
    echo "  $0 --clean                 Clean logs and start fresh"
    echo "  $0 --no-issues             Generate clean logs without issues"
    echo "  LOG_DIR=/tmp/logs $0       Use custom log directory"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--clean)
            CLEAN_LOGS=true
            shift
            ;;
        -d|--dir)
            LOG_DIR="$2"
            shift 2
            ;;
        -b|--burst)
            MANUAL_BURST=true
            shift
            ;;
        --no-issues)
            ENABLE_BROKEN_TIMESTAMPS="false"
            ENABLE_MISSING_FIELDS="false"
            ENABLE_MULTILINE_ISSUES="false"
            ENABLE_MIXED_FORMATS="false"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Clean logs if requested
if [[ "$CLEAN_LOGS" == "true" ]]; then
    echo -e "${YELLOW}Cleaning existing log files...${NC}"
    rm -f "${LOG_DIR}/${API_GATEWAY_LOG}" "${LOG_DIR}/${PAYMENT_SERVICE_LOG}" "${LOG_DIR}/${USER_SERVICE_LOG}" "${LOG_DIR}/${LEGACY_MONOLITH_LOG}" 2>/dev/null || true
fi

# Manual burst mode
if [[ "$MANUAL_BURST" == "true" ]]; then
    echo -e "${YELLOW}Triggering manual burst for all services...${NC}"
    generate_burst "api-gateway" 10
    generate_burst "payment-service" 10
    generate_burst "user-service" 10
    generate_burst "legacy-monolith" 10
    echo -e "${GREEN}Burst complete!${NC}"
    exit 0
fi

# Trap Ctrl+C
trap 'echo -e "\n${RED}Stopping log generator...${NC}"; exit 0' INT TERM

# Start main loop
main
