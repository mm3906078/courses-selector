import {
  Box,
  Icon,
  Stack,
  Text,
  useDisclosure,
  AlertDialog,
  AlertDialogBody,
  AlertDialogContent,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogOverlay,
  useToast,
  Button,
} from "@chakra-ui/react";
import { IoCalendarClearOutline } from "react-icons/io5";
import { LuClock } from "react-icons/lu";
import { MdOutlinePersonOutline } from "react-icons/md";
import { Course } from "../../../models/models";

import { useTranslation } from "react-i18next";
import { useRef } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { axiosInstance } from "../../../api/axiosInstance";

const StudentCourseBox = (props: Course) => {
  const { t } = useTranslation();

  const {
    isOpen: isSelectCourseConfirmOpen,
    onOpen: onOpenSelectCourseConfirm,
    onClose: onCloseSelectCourseConfirm,
  } = useDisclosure();
  const toast = useToast();
  const cancelRef = useRef(null);
  const queryClient = useQueryClient();

  const selectCourseMutation = useMutation({
    mutationFn: () => {
      return axiosInstance.post(`user/enroll/${props.course_id}`);
    },
    onSuccess: (res) => {
      onCloseSelectCourseConfirm();
      queryClient.invalidateQueries({ queryKey: ["selected-courses"] });
      toast({
        title: "Course Selected!",
        description: `course selected with id of ${res.data.course.course_id}`,
        status: "success",
        duration: 3000,
      });
    },
    onError(error: any) {
      toast({
        title: "Error!",
        description: `${error.response.data.error}`,
        status: "error",
        duration: 3000,
      });
    },
  });

  const formatDays = (days: string[]): string => {
    let formattedDays = "";
    days.forEach((day) => (formattedDays += `${t(day.toLowerCase())} - `));
    return formattedDays.substring(0, formattedDays.length - 2);
  };

  return (
    <>
      <Box
        borderRadius="15px"
        bg="#F3F4FF"
        padding="20px"
        cursor="pointer"
        transition="all .25s ease"
        _hover={{ transform: "scale(1.1)" }}
        onClick={onOpenSelectCourseConfirm}
      >
        <Text fontSize="lg">{props.name}</Text>
        <Stack mt="20px">
          <Text>
            <Icon as={MdOutlinePersonOutline} /> {props.professor}
          </Text>
          <Text>
            <Icon as={IoCalendarClearOutline} /> {formatDays(props.days)}
          </Text>
          <Text>
            <Icon as={LuClock} />{" "}
            <Text display="inline" dir="ltr">
              {props.time}
            </Text>
          </Text>
        </Stack>
      </Box>
      {isSelectCourseConfirmOpen && (
        <AlertDialog
          isCentered
          isOpen={isSelectCourseConfirmOpen}
          leastDestructiveRef={cancelRef}
          onClose={onCloseSelectCourseConfirm}
        >
          <AlertDialogOverlay>
            <AlertDialogContent>
              <AlertDialogHeader fontSize="lg" fontWeight="bold">
                {t("selectCourse")}
              </AlertDialogHeader>

              <AlertDialogBody>
                {t("selectCourseConfirmMessage")}
              </AlertDialogBody>

              <AlertDialogFooter>
                <Button ref={cancelRef} onClick={onCloseSelectCourseConfirm}>
                  {t("cancel")}
                </Button>
                <Button
                  colorScheme="green"
                  onClick={() => {
                    selectCourseMutation.mutate();
                  }}
                  marginStart={3}
                >
                  {t("select")}
                </Button>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialogOverlay>
        </AlertDialog>
      )}
    </>
  );
};

export default StudentCourseBox;
